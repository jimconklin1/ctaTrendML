PubEqPath.addLibPath('_util','_data','_platform','_database','_file','_date');

inDataPath = 'M:\PublicEquityQuant\LOEquity\DATA\input\';%fullfile(PubEqPath.dataPath(), 'RAPC', 'output'); 
outDataPath = 'M:\PublicEquityQuant\LOEquity\DATA\output\';%fullfile(PubEqPath.localDataPath(), 'RAPC', 'output'); 

weeklyDataTable = readtable(indataPath+"\\weeklyAssetData.csv");
quarterlyDataTable = readtable(indataPath+"\\quarterlyAssetData.csv");

dataSrc = "-";
cfg = getRapcConfig(dataSrc);

periodEndMonthStr = '2019-11-01';
if getenv('USERNAME')=="dpopov"
    cfg.saveToDb = true;
end
isOfficialStr = "Y"; % Y/N
estimateFlag = "E";  % A = Actual  ;  E = Estimate
insuranceCompany = "";
rawSubdir = 'Raw';
%cfg.startDt = '2001-01-01';

if dataSrc == "EH"
    cfg.adjustForTiming = false;
    periodEndMonthStr = '2018-12-01';
    cfg.startDt = '2006-02-01';
    % cfg.dbFundFilter = "f.dead = 'No' and f.fund_id > 55000";
    cfg.dbFundFilter = "" ..."f.dead = 'No' and "
        + " f.geographical_mandate in" ...
        + "('North America', 'Global')" +newline ...  "('Global', 'North America', 'Europe')" +newline ...
        + " and f.currency = 'USD'" +newline ... and fund_size_usd > 500000000" +newline ...
        + " and exists (select * from eh.fund_ts ts " +newline...
        + " where ts.fund_id = f.fund_id and ts.ts_type = 'AUM' " +newline...
        + " and ts.dt = last_day(date '"+periodEndMonthStr+"') " +newline...
        + " and ts.amount >500000000 )" ...
        + "";%+ " and f.fund_id > 25000";
    
    % Limit our data set to funds with at least 5Y of returns, for now.
    % (mainly to make it load faster, and make initial analysis a little
    % "easier")
    cfg.dbMinReturns = 60;
    cfg.EH.monthsAhead = 0;
    cfg.dbMaxCacheAge = 0;
    cfg.EH.cacheTag = "EH";
    rawSubdir = 'Raw_EH';
    cfg.saveToDb = false;
end % if

cfg.endDt = eomdate(datetime(periodEndMonthStr));

coreDb = Env.newPubEqCoreDb();
if dataSrc == "EH"
    outStruct = loadRapcEH(coreDb, cfg); 
else
    outStruct = loadRapcDb(coreDb, cfg, insuranceCompany); 
end %if
% checkReturnsData(cfg, outStruct);

outStruct = preProcRapcInput(outStruct, cfg);
unpack(outStruct); % rtns,factors,rfr,rtnsLong,factorsLong,hHeader,fHeader,volsHF,volsFact,equHFrtns,equFactorRtns,hfStyleMktVal,hfStyleWts,t0,tt0

[T,N] = size(rtns); 
[~,M] = size(factors); 

fExpos = computeFactorExposures(hHeader,rtns,rfr,fHeader,factors,cfg); 
if cfg.adjustForTiming
  tHeaders = replaceSpaceCharacter(cfg.headers.betaHeader,'_');
  timingTable = array2table([fExpos.timingBetaBlock],'RowNames',hHeader','VariableNames', tHeaders); 
end % if
% performance assumptions,
%     E[SR] E[vol] correlations:
rNames = {'MSCI_Wrld','Markit IG CDX NA','US_10yr','US_MBS','ARP_eqGlobQual','ARP_eqGlobVal','ARP_eqGlobMom','ARP_eqGlobLowVol'};
vNames = {'E_SR','E_vol','corr1','corr2','corr3','corr4','corr5','corr6','corr7','corr8'};
%      E_SRs:                                          E_vols:
xx = [[0.35; 0.3; 0.2; 0.25; 0.4; 0.4; 0.4; 0.4],[0.15; 0.02; 0.05; 0.025; 0.03; 0.05; 0.08; 0.08]];
wtsARP = [0.35, 0.25, 0.2, 0.2];
corrMat = corrcoef(factors(:,1:8)); 
omega = corr2cov(xx(:,2),corrMat);
xx0 = [xx,corrMat];
outData.perfAssTable = array2table(xx0,'RowNames',rNames,'VariableNames',vNames); 
alphaDecay = 0.667;
outStruct.fExpos = fExpos;
outStruct.omega = omega;
outStruct.corrMat = corrMat;
outStruct.wtsARP = wtsARP;
outStruct.alphaDecay = alphaDecay;

% Computations for Table 2: cols Rel Wt	($mm) E[SR]	E[SR_?]	E[ARP] E[SR_?] E[vol] E[vol_?] E[vol_ARP] E[vol_?]
%nn = mapStrings({'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
rNames = {'FullHFportfolio','EquityLS_HFs','GlobMacroQuant_HFs','EventDriven_HFs','Opportunistic_HFs','ARP','eqGlobQual','eqGlobVal','eqGlobMom','eqGlobLowVol','MSCI_Wrld','Markit IG CDX NA','US_MBS','US_10yr'};
vNames = {'RelWts','MktVal','E_SR','E_SR_beta','E_SR_ARP','E_SR_alpha','E_vol','E_vol_beta','E_vol_ARP','E_vol_alpha'}; 
if cfg.opt.processMV
    outData.expPerformanceTable1 = createExpectedPerformanceTable1(rNames,vNames,outStruct,outData.perfAssTable, cfg); 
end % if

% Table 2b: exposure analysis for individual managers
% Computations for Table 2b: cols RelWt, mktVal($mm) E[SR]	E[SR_beta]	E[SR_ARP] E[SR_alpha] E[vol] E[vol_beta] E[vol_ARP] E[vol_alpha]
tempSet = setdiff(hHeader,{'aigHFhist','aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},'stable'); 
hIndx = mapStrings(tempSet,hHeader); 
outStruct.ghIndx = hIndx;
%H = length(hIndx); 
rNames = hHeader(hIndx); 

fundPerformance = createExpectedPerformanceTable2(rNames,tempSet,hIndx,outStruct,outData.perfAssTable, cfg); 
outData.expPerformanceTable2 = fundPerformance.table;

% betas:
% Computations for Table 3a, cols: 
%     		?s all-in					    Correlations all-in				Correlations to alpha			
%  Item		MSCI_W	US_CDX  MBS  US_10y     MSCI_W	US_CDX	MBS	US_10y      MSCI_W	US_CDX	MBS	US_10y
rNames = {'FullHFportfolio','EquityLS_HFs','GlobMacroQuant_HFs','EventDriven_HFs','Opportunistic_HFs'}; % hHeader(nn)';
vNames = {'betaMSCI','beta5yrCDX','beta10yr','betaMBS','corrMSCI','corr5yrCDX','corr10yr','corrMBS','corrAlphMSCI','corrAlph5yrCDX','corrAlph10yr','corrAlphMBS'};
hIndx = mapStrings({'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
if cfg.opt.processMV
    outData.expsrTable1 = createExposureTable1(rNames,vNames,hIndx,outStruct); 
end % if
    
% computations for Table 3b, cols: 
%     		?s all-in					    Correlations all-in				Correlations to alpha			
%  Item     Value  Mom  Quality	Low-vol     Value  Mom  Quality	Low-vol     Value  Mom	Quality	Low-vol
vNames = {'betaEqQual','betaEqVal','betaEqMom','betaEqLowVol','corrEqQual','corrEqVal','corrEqMom','corrEqLowVol','corrAlphEqQual','corrAlphEqVal','corrAlphEqMom','corrAlphEqLowVol'};
if cfg.opt.processMV
    outData.expsrTable2 = createExposureTable2(rNames,vNames,hIndx,outStruct); 
end % if

% tables to print, export to Excel
% perfAssTable
% expPerformanceTable1
% expPerformanceTable2
% expsrTable1
% expsrTable2

% function to loop through all the HFs and aggregations for "1-pagers"
tempSet = setdiff(hHeader,{'aigHFhist','aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},'stable'); 
hIndx = mapStrings(tempSet,hHeader); 

alphaRtns.header = fExpos.hfHeader;
alphaRtns.dates  = outStruct.dates;
alphaRtns.values = fExpos.refinedAlphaTS;
%if fExpos.adjustForTiming
%    alphaRtns.values = alphaRtns.values + rmNaNs(fExpos.timingRtnMatrix);
%end % if

if dataSrc ~= "EH"
    outStruct.fundIdHeader = cellfun(@(x) outStruct.ref.funds.idMap(x),alphaRtns.header);
end % if
if cfg.opt.processReturnAttribution
  rAtt = attributeReturns(cfg, outStruct);
  outData.retAttribution = rAtt.tbl;
end % if

outData = postProcRapcOut(cfg, outStruct, outData);

ourTimeSeries2csv(alphaRtns, fullfile(outDataDir, rawSubdir, 'Alpha_Returns.csv'));
tblStruct2csvSet(outData, fullfile(outDataDir, rawSubdir));

if cfg.saveToDb
    alphaRtns.idHeader = outStruct.fundIdHeader;
    runId = coreDb.newRapcRun(isoStrToDate(periodEndMonthStr), datetime ...
        , estimateFlag, isOfficialStr, cfg.adjustForTiming);
    disp("Run ID = " + string(runId));
    hfIds = cellfun(@(x) outStruct.ref.funds.idMap(x),hHeader(hIndx));
    dimIds = arrayfun(@(x) outStruct.ref.dim.instruments(x),hfIds);

    saveRapc3dMat(coreDb, runId, rAtt.db, "Return Attribution");
    
    saveRapc2d(coreDb, runId, fundPerformance.var.v_2d, dimIds);
    saveRapc1d(coreDb, runId, fundPerformance.var.v_1d, dimIds);
    coreDb.saveRapcReturns(runId, "Raw Alpha Returns", alphaRtns);
    % TODO: Need to extend our data model to allow for 2-dimensional time
    % series. Then "Primary Alpha", "Refined Alpha", "Timing" all become
    % dimension #1 under "Raw Alpha Returns" RAPC output variable, and
    % dimension #2 is of course the instruments (hedge funds).
    % Until then we can only save 1 time series per RAPC run, or we can
    % "pollute" our 1-dimensional space with denormalized dimensions,
    % which is far from ideal.
    
    % coreDb.saveRapcReturns(runId, "Timing Returns, Total", outStruct.fExpos.timingRtnMatrix);
    coreDb.Conn.commit;
    
    if cfg.adjustForTiming
        timingRtns.header = fExpos.hfHeader;
        timingRtns.dates  = outStruct.dates;
        timingRtns.values = fExpos.timingRtnMatrix;
        timingRtns.idHeader = alphaRtns.idHeader;
        coreDb.saveRapcReturns(runId, "Timing Returns", timingRtns);
        coreDb.Conn.commit;
    end % if
end % if

if cfg.opt.processMV
    rc = gen1pagers(outStruct,hIndx,outData.expPerformanceTable2,fullfile(outDataDir, 'OnePagers')); 
end % if
