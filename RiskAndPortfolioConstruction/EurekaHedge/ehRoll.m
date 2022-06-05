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
periodEndMonthStr = '2009-01-01'; %end of the “seed” period and the first month for which alpha data will be available (first run of RAPC)
% cfg.dbFundFilter = "f.dead = 'No' and f.fund_id > 55000";
cfg.dbFundFilter = "" ..."f.dead = 'No' and "
    + "1=1 "... + " and f.geographical_mandate in ('North America', 'Global', 'Europe')" +newline ...  "('Global', 'North America', 'Europe')" +newline ...
    + " and currency = 'USD'" +newline ... and fund_size_usd > 500000000" +newline ...
    + " and exists (select ts.* from eh.fund_ts ts " +newline...
    + " where ts.fund_id = f.fund_id and ts.ts_type = 'AUM' " +newline... + " and ts.dt > last_day(date '"+periodEndMonthStr+"') " +newline...
    + " and ts.amount >=250000000 )" ... %Funds that have ever hit 250MM in their lifetime are selected
   ... + " and f.inception_date >= date '2000-01-01'"...
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
cfg.dbMaxCacheAge = 0;
% how many periods to run the rolling calculation for (+1)
cfg.EH.monthsAhead = months(periodEndMonthStr, '2020-06-01'); 
cfg.EH.cacheTag = "EH_Roll";
cfg.EH.loadAumTs = true;
rawSubdir = 'Raw_EH';

cfg.endDt = eomdate(datetime(periodEndMonthStr));

coreDb = Env.newPubEqCoreDb();
dbData = loadRapcEH(coreDb, cfg); 
t0 = find(dbData.equHFrtns.dates >= datenum(cfg.endDt),1,'first');

%horizons = [-1 36 24 12 6 3]; %time horizons (in months) used for alpha data where -1 gives the “Full” results
horizons = [-1 36 12];
lenT = length(dbData.equHFrtns.dates);

numFunds = length(dbData.equHFrtns.header);
aumOffset=12; %12 quarters. This variable is created for the AUMGrowth calculation.

calc.aum = nan(aumOffset,numFunds);

for t = 3 : 3 : t0-1 %The first available date for our aumTS data is 4/30/2007 so we assign t=3 to start with 6/30/2007 in this loop. Iterating every 3 months for 7 times leads to t hitting every quarter from 6/30/2007 to 12/31/2008. Adding the 5 rows of Nans (i=1:5) and the 7 additional quarters of data (i=6:12) to the calc.aum variable allows us to calculate AUMGrowth later on beginning on 3/31/2009.
    i = aumOffset - (t0-1 - t)/3;
    calc.aum(i,:) = dbData.aumTS(t,:)'; 
end %t 

for t = t0+2:3:lenT %Add 2 to t0 to start on Mar 2009
    outStruct = dbData;
    outStruct.equHFrtns = splitTimeSeries(outStruct.equHFrtns, outStruct.equHFrtns.dates(t)+1);
    outStruct.equFactorRtns = splitTimeSeries(outStruct.equFactorRtns, outStruct.equHFrtns.dates(t)+1);
    outStruct = preProcRapcInput(outStruct, cfg);
    fExpos = computeFactorExposures(outStruct.hHeader, outStruct.rtns ...
        , outStruct.rfr, outStruct.fHeader, outStruct.factors, cfg);
    
   % i = t - t0 +1; %monthly
     i = (t - t0+1)/3;  %quarterly  
     
   % calc.rAlphaRtn_01mo(i, :) = fExpos.refinedAlphaTS(end,:);
   % calc.pAlphaRtn_01mo(i, :) = fExpos.primaryAlphaTS(end,:);
    
    for h = horizons
        if h <= size(fExpos.refinedAlphaTS, 1)
            if h <=0 
           %     rAlphaTsSlice = fExpos.refinedAlphaTS;
                pAlphaTsSlice = fExpos.primaryAlphaTS;
                moStr = "Full";
            else
           %     rAlphaTsSlice = fExpos.refinedAlphaTS(t-h+1:end,:);
                pAlphaTsSlice = fExpos.primaryAlphaTS(t-h+1:end,:);
                moStr = string(num2str(h, '%02.f')) + "mo";
            end % if
            % Remove funds that have no return record for last month in window
            hasLastMoRtn = ~isnan(outStruct.equHFrtns.values(end,:));
          %  rAlphaTsSlice(:,~hasLastMoRtn) = NaN;
            pAlphaTsSlice(:,~hasLastMoRtn) = NaN;

           % rAlphaRtn = nanmean(rAlphaTsSlice)*12;
           % rAlphaVol = sqrt(12)*nanstd(rAlphaTsSlice);
            pAlphaRtn = nanmean(pAlphaTsSlice)*12;
            pAlphaVol = sqrt(12)*nanstd(pAlphaTsSlice);
        else
            nanStub = NaN(1,size(fExpos.refinedAlphaTS, 2));
           % rAlphaRtn = nanStub;
           % rAlphaVol = nanStub;
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
   calc.beta(i,:) = fExpos.beta(:,1)'; 
   calc.aum(i+aumOffset,:) = dbData.aumTS(t,:)'; 
   dates(i,:)=dbData.equHFrtns.dates(t,:); %Returns every quarter starting Mar 2009
end %for i

formatOut="yyyy-mm-dd";
dates_formatted=datestr(dates,formatOut); %Formatted list of dates

clear coreDb; % DB connections can't be serialized

fn = fullfile(outDataDir, "ehRollData.mat");
ensureParentDirExists(fn);
save(fn);

%eqIdx = find(strcmp(dbData.equFactorRtns.header, 'MSCIworld'), 1);
%draw.alpha = nanmean(calc.alphaRtn_lastMo, 2);
%draw.palpha = nanmean(calc.alphaRtn_lastMo, 2);
%draw.Eq = dbData.equFactorRtns.values(t0:lenT, eqIdx);



