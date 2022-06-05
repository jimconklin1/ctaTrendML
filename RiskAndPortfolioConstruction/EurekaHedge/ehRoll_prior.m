clear;
PubEqPath.addLibPath('_util','_data','_platform','_database','_file','_date');
outDataDir = fullfile(PubEqPath.localDataPath(), 'EH'); 

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
periodEndMonthStr = '2009-01-01';
% cfg.dbFundFilter = "f.dead = 'No' and f.fund_id > 55000";
cfg.dbFundFilter = "" ..."f.dead = 'No' and "
    + "1=1 " ... + " and f.geographical_mandate in ('North America', 'Global', 'Europe')" +newline ...  "('Global', 'North America', 'Europe')" +newline ...
    + " and currency = 'USD'" +newline ... and fund_size_usd > 500000000" +newline ...
    + " and exists (select ts.* from eh.fund_ts ts " +newline...
    + " where ts.fund_id = f.fund_id and ts.ts_type = 'AUM' " +newline... + " and ts.dt > last_day(date '"+periodEndMonthStr+"') " +newline...
    + " and ts.amount >100000000 )" ...
    + "";%+ " and f.fund_id > 25000";
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
cfg.EH.monthsAhead = months(periodEndMonthStr, '2019-06-01');
cfg.EH.cacheTag = "EH_Roll";
cfg.EH.loadAumTs = true;
rawSubdir = 'Raw_EH';

cfg.endDt = eomdate(datetime(periodEndMonthStr));

coreDb = Env.newPubEqCoreDb();
dbData = loadRapcEH(coreDb, cfg); 
t0 = find(dbData.equHFrtns.dates >= datenum(cfg.endDt),1,'first');

horizons = [-1 36 24 12 6 3];

lenT = length(dbData.equHFrtns.dates);

for t = t0:lenT
    outStruct = dbData;
    outStruct.equHFrtns = splitTimeSeries(outStruct.equHFrtns, outStruct.equHFrtns.dates(t)+1);
    outStruct.equFactorRtns = splitTimeSeries(outStruct.equFactorRtns, outStruct.equHFrtns.dates(t)+1);
    outStruct = preProcRapcInput(outStruct, cfg);
    fExpos = computeFactorExposures(outStruct.hHeader, outStruct.rtns ...
        , outStruct.rfr, outStruct.fHeader, outStruct.factors, cfg);
    
    i = t - t0 +1;

    calc.rAlphaRtn_01mo(i, :) = fExpos.refinedAlphaTS(end,:);
    calc.pAlphaRtn_01mo(i, :) = fExpos.primaryAlphaTS(end,:);
    
    for h = horizons
        if h <= size(fExpos.refinedAlphaTS, 1)
            if h <=0 
                rAlphaTsSlice = fExpos.refinedAlphaTS;
                pAlphaTsSlice = fExpos.primaryAlphaTS;
                moStr = "Full";
            else
                rAlphaTsSlice = fExpos.refinedAlphaTS(t-h+1:end,:);
                pAlphaTsSlice = fExpos.primaryAlphaTS(t-h+1:end,:);
                moStr = string(num2str(h, '%02.f')) + "mo";
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
        calc.("rAlphaRtn_" + moStr)(i, :) = rAlphaRtn;
        calc.("rAlphaVol_" + moStr)(i, :) = rAlphaVol;
        calc.("rAlphaSrp_" + moStr)(i, :) = rAlphaRtn ./ rAlphaVol;
        calc.("pAlphaRtn_" + moStr)(i, :) = pAlphaRtn;
        calc.("pAlphaVol_" + moStr)(i, :) = pAlphaVol;
        calc.("pAlphaSrp_" + moStr)(i, :) = pAlphaRtn ./ pAlphaVol;
        % calcH(hIdx).
    end % for hIdx
end %for i

clear coreDb; % DB connections can't be serialized

fn = fullfile(outDataDir, "ehRollData.mat");
ensureParentDirExists(fn);
save(fn);

%eqIdx = find(strcmp(dbData.equFactorRtns.header, 'MSCIworld'), 1);
%draw.alpha = nanmean(calc.alphaRtn_lastMo, 2);
%draw.palpha = nanmean(calc.alphaRtn_lastMo, 2);
%draw.Eq = dbData.equFactorRtns.values(t0:lenT, eqIdx);



