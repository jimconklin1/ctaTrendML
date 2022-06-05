clear;
PubEqPath.addLibPath('_util','_data','_platform','_database','_file','_date');
outDataDir = fullfile(PubEqPath.localDataPath(), 'EH2');
pyOutDataDir = fullfile(outDataDir, 'ml_to_python');

scriptFileName = mfilename('fullpath');
scriptPath = regexprep(scriptFileName, '[/\\][^/\\]*$','');
parentPath = regexprep(scriptPath, '[/\\][^/\\]*$','');
addpath(parentPath);

dataSrc = "EH";
cfg = getRapcConfig(dataSrc);

cfg.adjustForTiming = false;
% filter: date of the first return to load
%cfg.startDt = '2006-02-01';
cfg.startDt = '2007-04-01'; % start of time series for 'Markit IG CDX NA'
% end of "seed" period, i.e. first run of RAPC
firstPeriodStr = datestr(dateshift(datetime('2010-01-01'), 'end', 'month'), 'yyyy-mm-dd');
lastPeriodStr = datestr(dateshift(datetime('2021-03-01'), 'end', 'month'), 'yyyy-mm-dd');
monthsPerPeriod = 1;

totMonths = calmonths(caldiff([...
    dateshift(datetime(firstPeriodStr), 'start', 'month') ...
    , dateshift(datetime(lastPeriodStr), 'start', 'month')...
    ] , {'months'})) + 1;

monthRemainder = mod(totMonths, monthsPerPeriod);
if monthRemainder ~= 0
    error("Period length does not align with total periods. Length: " + string(monthsPerPeriod) + ". Remainder: " +string(monthRemainder));
end 

aumEverAchieved = 50*1000*1000;
%periodEndMonthStr = '2009-01-01';
% cfg.dbFundFilter = "f.dead = 'No' and f.fund_id > 55000";
cfg.dbFundFilter = "1=1"...% "f.dead = 'No' "...
    + " and f.geographical_mandate in ('North America', 'Global', 'Europe')" +newline ...  "('Global', 'North America', 'Europe')" +newline ...
    + " and f.closed = 'No' " +newline ...
    + " and exists (select ts.* from eh.fund_ts ts " +newline...
    + " where ts.fund_id = f.fund_id and ts.ts_type = 'AUM' " +newline... + " and ts.dt > last_day(date '"+periodEndMonthStr+"') " +newline...
    + " and ts.amount >="+ string(aumEverAchieved) +" )" ...
    + "";%+ " and f.fund_id > 25000";
  %  + " and currency = 'USD'" +newline ... and fund_size_usd > 500000000" +newline ...
startingAum = 0;
if startingAum >0
    cfg.db.dtStartFilter =  ...
        "select ts.fund_id, greatest(min(ts.dt), f.date_added) as dt"+newline... 
      + "  from eh.fund_ts ts "+newline... 
      + "  join eh.fund f on f.fund_id = ts.fund_id"+newline... 
      + " where ts.ts_type = 'AUM'"+newline... 
      + "   and ts.amount >=100*1000*1000"+newline... 
      + " group by ts.fund_id, f.date_added";
end % if aum

% Filter: how many non-empty returns is required in the seed period in
% order to be included in the analysis
cfg.dbMinReturns = 0;
cfg.dbMaxCacheAge = 1;
% how many periods to run the rolling calculation for (+1)
cfg.EH.monthsAhead = totMonths;
cfg.EH.cacheTag = "EH_Roll";
cfg.EH.loadAumTs = true;
rawSubdir = 'Raw_EH';

cfg.endDt = eomdate(datetime(firstPeriodStr));

coreDb = Env.newPubEqCoreDb();
dbData = loadRapcEH(coreDb, cfg); 
t0 = find(dbData.equHFrtns.dates >= datenum(cfg.endDt),1,'first');

horizons = [-1 36 24 15 12 6 3];
forceExactPeriodLength = false;

lenT = length(dbData.equHFrtns.dates);

for i = 1: (lenT - t0)/monthsPerPeriod
    t = t0 + i * monthsPerPeriod - 1;
    outStruct = dbData;
    outStruct.equHFrtns = splitTimeSeries(outStruct.equHFrtns, outStruct.equHFrtns.dates(t)+1);
    outStruct.equFactorRtns = splitTimeSeries(outStruct.equFactorRtns, outStruct.equHFrtns.dates(t)+1);
    outStruct = preProcRapcInput(outStruct, cfg);
    fExpos = computeFactorExposures(outStruct.hHeader, outStruct.rtns ...
        , outStruct.rfr, outStruct.fHeader, outStruct.factors, cfg);
    
    calc.rAlphaRtn_01mo(i, :) = fExpos.refinedAlphaTS(end,:);
    calc.pAlphaRtn_01mo(i, :) = fExpos.primaryAlphaTS(end,:);
    
    calc.betas{1}(i,:) = fExpos.beta(:,1)';
    calc.dates(i, 1) = datetime(datestr(dbData.equHFrtns.dates(t)));
    
    for h = horizons
        if h <=0 
            moStr = "Full";
        else
            moStr = string(num2str(h, '%02.f')) + "mo";
        end % if
        
        enoughPeriods = (h <= size(fExpos.refinedAlphaTS, 1));

        if ~forceExactPeriodLength && ~enoughPeriods && (~( (h == 36) && (i<=5)))
            % There is not enough data to calculate SR(36mo) for the
            % first two periods. We let it be fewer periods in that
            % case. Any other case we are in here means some parameters
            % changed, so we need to know it and review the new data
            % befroe we consume it
            throw MException('not enough data to calculate SR')
        end % if
        
        if ~forceExactPeriodLength || enoughPeriods 
            if h <=0 
                rAlphaTsSlice = fExpos.refinedAlphaTS;
                pAlphaTsSlice = fExpos.primaryAlphaTS;
            else
                startIdx = max(t-h+1, 1);
                rAlphaTsSlice = fExpos.refinedAlphaTS(startIdx:end,:);
                pAlphaTsSlice = fExpos.primaryAlphaTS(startIdx:end,:);
            end % if
            % Remove funds that have no return record for last month in window
            hasLastMoRtn = ~isnan(outStruct.equHFrtns.values(end,:));
            rAlphaTsSlice(:,~hasLastMoRtn) = NaN;
            pAlphaTsSlice(:,~hasLastMoRtn) = NaN;

            rAlphaRtn = nanmean(rAlphaTsSlice)*12;
            rAlphaVol = sqrt(12)*nanstd(rAlphaTsSlice);
            pAlphaRtn = nanmean(pAlphaTsSlice)*12;
            pAlphaVol = sqrt(12)*nanstd(pAlphaTsSlice);
        else
            nanStub = NaN(1,size(fExpos.refinedAlphaTS, 2));
            rAlphaRtn = nanStub;
            rAlphaVol = nanStub;
            pAlphaRtn = nanStub;
            pAlphaVol = nanStub;
        end % if h
        %calc.("rAlphaRtn_" + moStr)(i, :) = rAlphaRtn;
        %calc.("rAlphaVol_" + moStr)(i, :) = rAlphaVol;
        %calc.("rAlphaSrp_" + moStr)(i, :) = rAlphaRtn ./ rAlphaVol;
        calc.("pAlphaRtn_" + moStr)(i, :) = pAlphaRtn;
        calc.("pAlphaVol_" + moStr)(i, :) = pAlphaVol;
        calc.("pAlphaSrp_" + moStr)(i, :) = pAlphaRtn ./ pAlphaVol;
        % calcH(hIdx).
    end % for hIdx
end %for i

clear coreDb; % DB connections can't be serialized

fn_suff = string(monthsPerPeriod) + "mo";

fn = fullfile(outDataDir, "eh2_RollData_" + fn_suff +".mat");
ensureParentDirExists(fn);
save(fn);

% exports for Python
calc_py = rmfield(calc, 'dates');
calc_py.dates_chr = datestr(calc.dates, 'yyyy-mm-dd'); % caution: format different from DateTime.Format (yyyy-MM-dd)

dbData_py.equHFrtns     = dbData.equHFrtns    ;
dbData_py.aumTS         = dbData.aumTS        ;
dbData_py.equFactorRtns = dbData.equFactorRtns;
dbData_py.fundIdHeader  = dbData.fundIdHeader ;
dbData_py.aumEverAchieved = aumEverAchieved;

py_fn = fullfile(pyOutDataDir, "eh2_" + fn_suff +".mat");
save(py_fn, 'calc_py', 'dbData_py', 'firstPeriodStr', 'lastPeriodStr'...
    , 'monthsPerPeriod');



