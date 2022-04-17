%% runNaiveTrend2.m                                            JConklin
%  runs a simple trend following model.  Has draw-down control and 
%    non draw-down control variants

%  inputs: 
%    assetUniverse = 'futures', 'ccy', 'combined'
%    simPath = 'dailySimulatorJC\simulationXX\'
%    dataPath = 'S:\quantQA\DATA\signal\naiveTrend'
%    verbose = true \ false

% [portSim1, portSim2, portSim3, signal1, signal2, signal3] = ...
%            runNaiveTrend2('combined',[],true)

%  key configuration files: 
%    configuration is done in *.m files located in [simPath,'naiveTrend\'].  The 
%    files *MUST* include:
%       calcSignal.m
%       configSim.m
%       configSimData.m
%       configPortConstruction.m
%    other *.m files may be added if called by the four functions
%    above.

function [portSim, dataConfig] = runNaiveTrend2(assetUniverse,ctx,executionTZ,verbose,trendType)
%% initialize environment (paths, variable/global declaration, etc.):
if nargin < 5 || isempty('verbose') 
   verbose = false; 
end

config = ctx.conf;

if nargin >= 2 && isfield(config,'customEndDate')
   if ischar(config.customEndDate)
      config.simEndDate = datenum(config.customEndDate);
   else
      config.simEndDate = config.customEndDate; 
   end 
else 
   config.simEndDate = today(); 
end

simPath = config.simPath; % e.g., 'H:\GIT\quantSignals\model_NaiveTrend\';
dataPath = config.dataPath; % e.g., 'S:\quantQA\DATA\signal\naiveTrend\';

if nargin < 1 || sum(size(assetUniverse))==0
   assetUniverse = 'combined'; % 'fx','futures' 
end

%% configure simulation, routines in simPath
config = configSim(dataPath,simPath,config); 
dataConfig = configSimData2b(config,assetUniverse,dataPath); 
portConfig = configPortConstruction2(dataConfig);
riskConfig = configRisk();

%% data:
% pull in data on dependent variables (ccy returns) and data for
% independent variables for each time zone: 
% dataStr = [config.signalOutputPath,'output\simInputData.mat assetDataPx assetDataTK equityDataTK ',...
%     'ratesDataTK comdtyDataTK assetDataLN equityDataLN ratesDataLN comdtyDataLN assetDataLN ',...
%     'equityDataLN ratesDataLN comdtyDataLN;'];
% evel(['load ',dataStr]);
% dataConfigCurr = dataConfig;
try 
    if config.refreshInputData
        disp('re-building InputData! '); 
        error ('refreshing InputData! ')
    end 
    dataStr = [config.signalOutputPath,'output\simInputData.mat assetDataTK equityDataTK ',...
      'ratesDataTK comdtyDataTK ccyDataTK assetDataLN equityDataLN ratesDataLN comdtyDataLN ccyDataLN ',...
      ' assetDataNY equityDataNY ratesDataNY comdtyDataNY ccyDataNY;'];
    eval(['load ',dataStr]); 
    dates0 = [assetDataTK.dates(end); equityDataTK.dates(end); ratesDataTK.dates(end); ...
                 comdtyDataTK.dates(end); ccyDataTK.dates(end); ...
              assetDataLN.dates(end); equityDataLN.dates(end); ratesDataLN.dates(end); ...
                 comdtyDataLN.dates(end); ccyDataLN.dates(end); ...
              assetDataNY.dates(end); equityDataNY.dates(end); ratesDataNY.dates(end); ...
                 comdtyDataNY.dates(end); ccyDataNY.dates(end)]; %#ok<NODEF>
    date0 = floor(busdate(min(dates0)-config.spliceBusdays)); 
    config2 = config;
    dataConfig2 = dataConfig;
    dataConfig2.startDate = date0; 
    dataConfig2.equity.startDates = repmat(dataConfig2.startDate,size(dataConfig2.equity.startDates));
    dataConfig2.rates.startDates = repmat(dataConfig2.startDate,size(dataConfig2.rates.startDates));
    dataConfig2.comdty.startDates = repmat(dataConfig2.startDate,size(dataConfig2.comdty.startDates));
    dataConfig2.ccy.startDates = repmat(dataConfig2.startDate,size(dataConfig2.ccy.startDates));
    config2.simStartDate = date0; 
    config2.dataStartDate = date0; 
    [assetDataTKn,equityDataTKn,ratesDataTKn,comdtyDataTKn, ...
             ccyDataTKn] = buildTrendDatasets(config2,dataConfig2,assetUniverse,'TK',ctx.bbgConn); 
    [assetDataLNn,equityDataLNn,ratesDataLNn,comdtyDataLNn, ...
             ccyDataLNn] = buildTrendDatasets(config2,dataConfig2,assetUniverse,'LN',ctx.bbgConn); 
    [assetDataNYn,equityDataNYn,ratesDataNYn,comdtyDataNYn, ...
             ccyDataNYn] = buildTrendDatasets(config2,dataConfig2,assetUniverse,'NY',ctx.bbgConn); 

    assetDataTK = spliceDataStruct(assetDataTK,assetDataTKn,date0,'header','startDates','endDates','holidays',[],...
                                   'close','range'); 
    equityDataTK = spliceDataStruct(equityDataTK,equityDataTKn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    ratesDataTK = spliceDataStruct(ratesDataTK,ratesDataTKn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');   
    comdtyDataTK = spliceDataStruct(comdtyDataTK,comdtyDataTKn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');   
    ccyDataTK = spliceDataStruct(ccyDataTK,ccyDataTKn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');   
    assetDataLN = spliceDataStruct(assetDataLN,assetDataLNn,date0,'header','startDates','endDates',[],...
                                   'holidays','close','range'); 
    equityDataLN = spliceDataStruct(equityDataLN,equityDataLNn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range'); 
    ratesDataLN = spliceDataStruct(ratesDataLN,ratesDataLNn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    comdtyDataLN = spliceDataStruct(comdtyDataLN,comdtyDataLNn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    ccyDataLN = spliceDataStruct(ccyDataLN,ccyDataLNn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    assetDataNY = spliceDataStruct(assetDataNY,assetDataNYn,date0,'header','startDates','endDates',[],...
                                   'holidays','close','range'); 
    equityDataNY = spliceDataStruct(equityDataNY,equityDataNYn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    ratesDataNY = spliceDataStruct(ratesDataNY,ratesDataNYn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    comdtyDataNY = spliceDataStruct(comdtyDataNY,comdtyDataNYn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range'); 
    ccyDataNY = spliceDataStruct(ccyDataNY,ccyDataNYn,date0,'header','startDates','endDates','timezone',...
                                   'holidays','close','range');  
    eval(['save ',dataStr]); 
catch
    [assetDataTK,equityDataTK,ratesDataTK,comdtyDataTK, ...
             ccyDataTK] = buildTrendDatasets(config,dataConfig,assetUniverse,'TK',ctx.bbgConn);  
    [assetDataLN,equityDataLN,ratesDataLN,comdtyDataLN, ...
             ccyDataLN] = buildTrendDatasets(config,dataConfig,assetUniverse,'LN',ctx.bbgConn);  
    [assetDataNY,equityDataNY,ratesDataNY,comdtyDataNY, ...
             ccyDataNY] = buildTrendDatasets(config,dataConfig,assetUniverse,'NY',ctx.bbgConn);  
    dataStr = [config.signalOutputPath,'output\simInputData.mat assetDataTK equityDataTK ',...
      'ratesDataTK comdtyDataTK ccyDataTK assetDataLN equityDataLN ratesDataLN comdtyDataLN ccyDataLN ',...
      ' assetDataNY equityDataNY ratesDataNY comdtyDataNY ccyDataNY;'];
    eval(['save ',dataStr]); 
end 

% covmtx = calcRiskMatrixRobust(assetDataLN,assetPxData,riskConfig);
covmtxTK = calcRiskMatrix2(assetDataTK,riskConfig);
covmtxLN = calcRiskMatrix2(assetDataLN,riskConfig);
covmtxNY = calcRiskMatrix2(assetDataNY,riskConfig);
% covmtx = cat(3,covmtxLN(:,:,1),covmtxLN(:,:,1:end-1));
% datesCov = assetDataLN.dates;
[covmtx, datesCov] = combineTZriskMats(covmtxTK,assetDataTK.dates,covmtxLN,assetDataLN.dates,...
                                       covmtxNY,assetDataNY.dates,executionTZ,dataConfig); 

% If the forward position generation logic was invoked... extend the dataset:
 if isfield(ctx.conf,'forwardPosn') && ctx.conf.forwardPosn
   noPeriods = 3;
   grossPerturbation = 4; 
   eqIndx = mapStrings(dataConfig.equity.header,assetDataTK.header,false);
   rtIndx = mapStrings(dataConfig.rates.header,assetDataTK.header,false);
   cmIndx = mapStrings(dataConfig.comdty.header,assetDataTK.header,false);
   cyIndx = mapStrings(dataConfig.ccy.header,assetDataTK.header,false);

   volVec = (diag(squeeze(covmtxTK(:,:,end))).^.5)';
   assetDataTK = extendDatasetForward(assetDataTK,volVec,noPeriods,grossPerturbation); 
   equityDataTK = extendDatasetForward(equityDataTK,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ratesDataTK = extendDatasetForward(ratesDataTK,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   comdtyDataTK = extendDatasetForward(comdtyDataTK,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ccyDataTK = extendDatasetForward(ccyDataTK,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   
   volVec = (diag(squeeze(covmtxLN(:,:,end))).^.5)';
   assetDataLN = extendDatasetForward(assetDataLN,volVec,noPeriods,grossPerturbation); 
   equityDataLN = extendDatasetForward(equityDataLN,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ratesDataLN = extendDatasetForward(ratesDataLN,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   comdtyDataLN = extendDatasetForward(comdtyDataLN,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ccyDataLN = extendDatasetForward(ccyDataLN,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 

   volVec = (diag(squeeze(covmtxNY(:,:,end))).^.5)';
   assetDataNY = extendDatasetForward(assetDataNY,volVec,noPeriods,grossPerturbation); 
   equityDataNY = extendDatasetForward(equityDataNY,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ratesDataNY = extendDatasetForward(ratesDataNY,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   comdtyDataNY = extendDatasetForward(comdtyDataNY,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
   ccyDataNY = extendDatasetForward(ccyDataNY,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
end

switch executionTZ
   case 'postTokyoClose' 
      assetDataPx = assetDataLN;
   case 'postLondonClose' 
      assetDataPx = assetDataNY;
   case 'postNYClose' 
      assetDataPx = assetDataTK;
end 

timeZones = {'TK','LN','NY'};
switch trendType
%     case 'EXPXO'
%         [signal, ~, portConfig] = calcExpxoSignal(config,dataConfig,portConfig);
%         portSim = constructPortfolioGM3(assetData,signal,covmtx,dataConfig,portConfig);
%         displayPnl(portSim, trendType, verbose);
    case 'MMA'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i}]);
           eval(['ratesData = ratesData',timeZones{i}]);
           eval(['comdtyData = comdtyData',timeZones{i}]); 
           eval(['ccyData = ccyData',timeZones{i}]);
           [signal, signalCube, portConfig] = calcMmaSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},' = signal']); 
           eval(['signalCube',timeZones{i},' = signalCube']); 
        end % for 
        signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSim = constructPortfolioGM4(assetDataPx,signal,covmtx,datesCov,dataConfig,portConfig);
        displayPnl(portSim, trendType, verbose);
    case 'MBO'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i}]);
           eval(['ratesData = ratesData',timeZones{i}]);
           eval(['comdtyData = comdtyData',timeZones{i}]); 
           eval(['ccyData = ccyData',timeZones{i}]);
           [signal, signalCube, portConfig] = calcMboSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},' = signal']); 
           eval(['signalCube',timeZones{i},' = signalCube']); 
        end % for 
        signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSim = constructPortfolioGM4(assetDataPx,signal,covmtx,datesCov,dataConfig,portConfig); 
        displayPnl(portSim, trendType, verbose);
    case 'MMO'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal, signalCube, portConfig] = calcMmoSignal(config,dataConfig,portConfig,timeZones{i}); %#ok<ASGLU>
           eval(['signal',timeZones{i},' = signal;']); 
           eval(['signalCube',timeZones{i},' = signalCube;']); 
        end % for 
        signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSim = constructPortfolioGM4(assetDataPx,signal,covmtx,datesCov,dataConfig,portConfig); 
        displayPnl(portSim, trendType, verbose);
    case 'TSTAT'
        spliceDatesTimeZones= nan(1,length(timeZones));
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           try 
               if ~config.tstat.spliceOption
                   disp('spliceOption is false for tstat, refreshing tstat structure! '); 
                   error ('spliceOption is false for tstat, refreshing tstat structure!')
               end 
               eval(['load ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw ;'])
               dates0= zeros (length (signal.subStrat),1);
               for j =1:length (signal.subStrat)
                    dates0(j) =  signal.subStrat(j).dates(end); 
               end 
               date0 = floor(busdate(min(dates0)-config.tstat.spliceBusdays)); 
               spliceDatesTimeZones(i)= date0; 
               [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignal(config,dataConfig,portConfig, date0, timeZones{i}); 
               signal = spliceSignalStruct( signal, signalNew ,date0   );   
               signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
               tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
           catch
               spliceDatesTimeZones(i) = nan;
               [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
           end 
           eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
           eval(['signal',timeZones{i},' = signal;']); 
           eval(['signalCube',timeZones{i},' = signalCube;']); 
           eval(['tstatCubeRaw',timeZones{i},' = tstatCubeRaw;']); 
        end % for 
        storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
        signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSim = constructPortfolioGM4(assetDataPx,signal,covmtx,datesCov,dataConfig,portConfig); 
        portSim.totTC=   nansum(portSim.tc, 2);
        displayPnl(portSim, trendType, verbose);
    case 'Combined'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal, signalCube, portConfig] = calcMmaSignal(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},' = signal;']);
           eval(['signalCube',timeZones{i},' = signalCube;']);
        end % for 
        signalMMA = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSimMMA = constructPortfolioGM4(assetDataPx,signalMMA,covmtx,datesCov,dataConfig,portConfig);
%         displayPnl(portSimMMA, 'MMA', verbose);
        
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal,signalCube, portConfig] = calcMboSignal(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},' = signal;']);
           eval(['signalCube',timeZones{i},' = signalCube;']);
        end % for 
        signalMBO = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSimMBO = constructPortfolioGM4(assetDataPx,signalMBO,covmtx,datesCov,dataConfig,portConfig);
%         displayPnl(portSimMBO, 'MBO', verbose);
        
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal, ~, portConfig] = calcMmoSignal(config,dataConfig,portConfig,timeZones{i});
           eval(['signal',timeZones{i},' = signal;']); 
        end % for 
        signalMMO = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSimMMO = constructPortfolioGM4(assetDataPx,signalMMO,covmtx,datesCov,dataConfig,portConfig);
%         displayPnl(portSimMMO, 'MMO', verbose);
        
%         portSim = combineTrendPorts(portSimMBO, portSimMMA, portSimMMO, [0.35,0.35,0.3]);
%         displayPnl(portSim, trendType, verbose);

        spliceDatesTimeZones= nan(1,length(timeZones));
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           try 
               if ~config.tstat.spliceOption
                   disp('spliceOption is false for tstat, refreshing tstat structure!');
                   error ('spliceOption is false for tstat, refreshing tstat structure!')
               end 
               eval(['load ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw ;'])
               dates0= zeros (length (signal.subStrat),1);
               for j =1:length (signal.subStrat)
                    dates0(j) =  signal.subStrat(j).dates(end); 
               end 
               date0 = floor(busdate(min(dates0)-config.tstat.spliceBusdays)); 
               spliceDatesTimeZones(i) = date0; 
               [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignal(config,dataConfig,portConfig, date0, timeZones{i}); 
               signal = spliceSignalStruct( signal, signalNew ,date0   );   
               signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
               tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
           catch
               spliceDatesTimeZones(i) = nan; 
               [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
           end 
           eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
           eval(['signal',timeZones{i},' = signal;']); 
           eval(['signalCube',timeZones{i},' = signalCube;']); 
           eval(['tstatCubeRaw',timeZones{i},' = tstatCubeRaw;']); 
        end % for 
        %storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
        signalTSTAT = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        portSimTSTAT = constructPortfolioGM4(assetDataPx,signalTSTAT,covmtx,datesCov,dataConfig,portConfig); 
        portSimTSTAT.totTC = nansum(portSimTSTAT.tc, 2);
        
        % blend signal prior to port const... more or less the same:
        signalAll = combineTrendSignals(signalMMA,signalMBO,signalMMO,signalTSTAT,[],[0.25,0.25,0.25,0.25]);
        portSimAll = constructPortfolioGM4(assetDataPx,signalAll,covmtx,datesCov,dataConfig,portConfig);
        portSim = portSimAll;
        portSim = computeTrades(portSim, portSimMMA, portSimMBO, portSimMMO,portSimTSTAT, dataConfig);
        if verbose
           portConfig.rebalTol = (1./(16*nanstd(assetDataPx.close)))*(15000/25000000); 
           portSimAll = constructPortfolioGM4(assetDataPx,signalAll,covmtx,datesCov,dataConfig,portConfig);
           portSimAll.turnover = (260)*sum(abs(portSimAll.wts(2:end,:)-portSimAll.wts(1:end-1,:)),2);
           plot(portSimAll.dates(2:end,:),ma(portSimAll.turnover,10)); datetick('x','mmmyy'); grid; title('2-wk annualized turnover')
           displayPnl(portSimAll, trendType, verbose);
           % [labels,stats]=displayPnLstatTable(portSim);
        end % if
    otherwise
        warning('Unexpected trend type.');
end % switch

if isfield(ctx.conf,'forwardPosn') && ctx.conf.forwardPosn
   tT1 = find(floor(portSim.dates)>=floor(datenum(ctx.startTime)),1);
   wtsDiff = portSim.wts(end,:) - portSim.wts(tT1,:); 
   sigDiff = portSim.rawSig(end,:) - portSim.rawSig(tT1,:); 
   tmpVar = [100*portSim.wts(tT1,:); 100*wtsDiff; portSim.rawSig(tT1,:); sigDiff]; 
   portSim.names = portSim.header;
   for i = 1:length(portSim.header) 
       tmpStr = {portSim.header{i}(1:2)};
       if strcmp(tmpStr,'fx')
          tmpStr = {portSim.header{i}(4:end)}; 
       end 
       portSim.names(i) = tmpStr;
   end
   eqTbl = array2table(tmpVar(:,eqIndx),'VariableNames',portSim.names(:,eqIndx),'RowNames',{'currWts','chngWts','currSig','chngSig'});
   rtTbl = array2table(tmpVar(:,rtIndx),'VariableNames',portSim.names(:,rtIndx),'RowNames',{'currWts','chngWts','currSig','chngSig'});
   cmTbl = array2table(tmpVar(:,cmIndx),'VariableNames',portSim.names(:,cmIndx),'RowNames',{'currWts','chngWts','currSig','chngSig'});
   cyTbl = array2table(tmpVar(:,cyIndx),'VariableNames',portSim.names(:,cyIndx),'RowNames',{'currWts','chngWts','currSig','chngSig'});
end % if
eval(['save ',config.signalOutputPath,'output\simResults.mat portSim signalAll config dataConfig portConfig;'])

end % fn
