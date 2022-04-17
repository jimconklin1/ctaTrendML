%% runDailySim2.m                                            JConklin
%  runs a generalized simulation routine from signal generation, 
%  portfolio construction, draw-down control, to PnL computation.

%  inputs: 
%    assetUniverse = 'futures', 'ccy', 'combined'
%    simPath = 'dailySimulatorJC\simulationXX\'
%    verbose = true \ false

%  key configuration files: 
%    configuration is done in *.m files located in simPath.  The 
%    files *MUST* include:
%       calcSignal.m
%       configSim.m
%       configSimData.m
%       configPortConstruction.m
%    other *.m files may be added if called by the four functions
%    above.

function [portSim, signal] = runDailySim2(assetUniverse,simPath,customEndDate,verbose)
%% initialize environment (paths, variable/global declaration, etc.):
if nargin < 4 || isempty('verbose') 
   verbose = false; 
end

if nargin >= 3 || exist('customEndDate') %#ok
   if ischar(customEndDate)
      customEndDate = datenum(customEndDate);
   end 
   config.simEndDate = customEndDate; 
else
   config = [];
end

homePath = 'C:\Research\quantLib\dailySimulator\';
if nargin < 2 || isempty('simPath')
   simPath = [homePath,'simulationTrend_wDD\']; % 'simulationTrend_wDD\' 'simulationRP1_wDD\' 'simulationVarPremia_wDD\'
else 
   simPath = [homePath,simPath]; 
end 

if nargin < 1 || sum(size(assetUniverse))==0
   assetUniverse = 'futures'; % 'fx', 'combined'
end 

eval(['addpath ',homePath]) 
eval(['addpath ',homePath,'_util_simulation\;']) 
eval('addpath C:\Research\quantLib\utils\;') 
eval('addpath C:\Research\quantLib\utils\utilsData\;') 
eval('addpath C:\Research\quantLib\utils\utilsJC\;') 
eval(['addpath ',simPath,';']) 
eval(['cd ',simPath,';']) 

%% configure simulation, routines in simPath
config = configSim(homePath,simPath,config); 
dataConfig = configSimData(config,assetUniverse); 
portConfig = configPortConstruction(dataConfig); 

%% data:
% pull in data on dependent variables (ccy returns) and data for independent variables:
if strcmpi(assetUniverse(1:3),'all')||strcmpi(assetUniverse,'combined')
    ratesData = getDailyReturnData(dataConfig.rates);
    ccyData = getDailyReturnData(dataConfig.ccy);
    comdtyData = getDailyReturnData(dataConfig.comdty);
    equityData = getDailyReturnData(dataConfig.equity);
    
    assetData.header = [ratesData.header',ccyData.header',comdtyData.header',equityData.header'];
    if config.dataStartDate < config.simStartDate
        ratesData2 = startDataTrunc(ratesData,config);
        ccyData2 = startDataTrunc(ccyData,config);
        comdtyData2 = startDataTrunc(comdtyData,config);
        equityData2 = startDataTrunc(equityData,config);
        assetData.dates = ratesData2.dates;
        assetData.values = [ratesData2.values,ccyData2.values,comdtyData2.values,equityData2.values];
    else
        assetData.dates = ratesData.dates;
        assetData.values = [ratesData.values,ccyData.values,comdtyData.values,equityData.values];
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));
elseif strcmpi(assetUniverse(1:3),'ccy') || strcmpi(assetUniverse(1:3),'cur')
    ccyData = getAssetData(dataConfig.ccy);   
    assetData.header = ccyData.header'; 
    if config.dataStartDate < config.simStartDate 
        ccyData2 = startDataTrunc(ccyData,config); 
        assetData.dates = ccyData2.dates; 
        assetData.values = ccyData2.values; 
    else
        assetData.dates = ccyData.dates;
        assetData.values = ccyData.values; 
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));
elseif strcmp(assetUniverse,'futures')
    ratesData = getDailyReturnData(dataConfig.rates);
    comdtyData = getDailyReturnData(dataConfig.comdty);
    equityData = getDailyReturnData(dataConfig.equity);
    assetData.header = [ratesData.header,comdtyData.header,equityData.header];
    if config.dataStartDate < config.simStartDate
        ratesData2 = startDataTrunc(ratesData,config);
        comdtyData2 = startDataTrunc(comdtyData,config);
        equityData2 = startDataTrunc(equityData,config);
        assetData.dates = ratesData2.dates;
        assetData.values = [ratesData2.values,comdtyData2.values,equityData2.values];
    else
        assetData.dates = ratesData.dates;
        assetData.values = [ratesData.values,comdtyData.values,equityData.values];
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));
end % if

%% construct signals:
[signal, auxCalcs, portConfig] = calcSignal(config,dataConfig,portConfig,verbose); %#ok

%% portfolio construction:
if strcmp(config.stratName,'barcapVolHarvest')%|| strcmp(config.stratName,'riskParity')
   % estimate risk matrix:
   omega = calcRisk(assetData,config,dataConfig,portConfig,[45,20,260]); 

   % compute dynamic correlations amoung major asset classes:
   if strcmpi(portConfig.method,'corrParity')
      assetClass = calcDynCorr(assetData,config,dataConfig); 
      portConfig = calcRelAssetClassWts(assetClass,config,portConfig); 
   end 
   
   % portfolio positions from the signals: 
   portSim = constructPortfolioAltBeta(assetData,signal,omega,config,dataConfig,portConfig);
else 
   % compute dynamic correlations amoung major asset classes:
   if strcmpi(portConfig.method,'corrParity')
      assetClass = calcDynCorr(assetData,config,dataConfig); 
      portConfig = calcRelAssetClassWts(assetClass,config,portConfig); 
   elseif strcmpi(portConfig.method,'varyingPremia')
      portConfig = calcDynCorrAssetClassWts(equityData,ratesData,comdtyData,signal,config,portConfig); 
   end 
   % portfolio positions from the signals: 
   portSim = constructPortfolioGM2(assetData,signal,config,dataConfig,portConfig,'hl',[45,20,260]); 
end 
eval(['save ',simPath,'output\simResults.mat portSim signal config dataConfig portConfig assetData;'])
figure(2); plot(portSim.dates,calcCum(portSim.totPnl,0)); datetick('x','yyyy'); grid
disp(['The Sharpe ratio of the simulation PnL is ',num2str(16*nanmean(portSim.totPnl)/nanstd(portSim.totPnl))])
disp(['The Sharpe ratio of the equity sim PnL is ',num2str(16*nanmean(portSim.subStrat(1).totPnl)/nanstd(portSim.subStrat(1).totPnl))])
disp(['The Sharpe ratio of the rates sim  PnL is ',num2str(16*nanmean(portSim.subStrat(2).totPnl)/nanstd(portSim.subStrat(2).totPnl))])
disp(['The Sharpe ratio of the comdty sim PnL is ',num2str(16*nanmean(portSim.subStrat(3).totPnl)/nanstd(portSim.subStrat(3).totPnl))])
end % fn

function assetData2 = adjustBarCapRtnsForFees(assetData,dataConfig) %#ok
feeTable = [dataConfig.assetIDs',dataConfig.fees']; 
assetData2 = assetData;
T = length(assetData.values); 
for k = 1:dataConfig.numAssets
    kk = find(strcmp(assetData.header(k),feeTable(:,1))); 
    t1 = find(assetData.dates==dataConfig.startDates(k)); 
    temp = repmat(feeTable{kk,2}/(10000*260),[T-t1+1,1]); %#ok
    assetData2.values(t1:end,k) = assetData.values(t1:end,k) - temp; 
end % k
end % fn
