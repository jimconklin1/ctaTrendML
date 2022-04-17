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

function [portSimAll, dataConfig] = runNaiveTrendFwd(assetUniverse,ctx,executionTZ,verbose,trendType)
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
riskConfig = configRisk(dataConfig);

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
    %eval(['save ',dataStr]); 
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
    %eval(['save ',dataStr]); 
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
 %if isfield(ctx.conf,'forwardPosn') && ctx.conf.forwardPosn
    noPeriods = 5; 
    grossPerturbation = sqrt(5)*1; % in daily stdevs
    eqIndx = mapStrings(dataConfig.equity.header,assetDataTK.header,false);
    rtIndx = mapStrings(dataConfig.rates.header,assetDataTK.header,false);
    cmIndx = mapStrings(dataConfig.comdty.header,assetDataTK.header,false);
    cyIndx = mapStrings(dataConfig.ccy.header,assetDataTK.header,false);

    covmtxExt = cat(3,covmtx,repmat(covmtx(:,:,end),[1,1,noPeriods])); 
    volVec = (diag(squeeze(covmtxTK(:,:,end))).^.5)';
    assetDataTKu = extendDatasetForward(assetDataTK,volVec,noPeriods,grossPerturbation); 
    datesCovExt = assetDataTKu.dates;
    equityDataTKu = extendDatasetForward(equityDataTK,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ratesDataTKu = extendDatasetForward(ratesDataTK,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    comdtyDataTKu = extendDatasetForward(comdtyDataTK,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ccyDataTKu = extendDatasetForward(ccyDataTK,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    assetDataTKd = extendDatasetForward(assetDataTK,volVec,noPeriods,-grossPerturbation); 
    equityDataTKd = extendDatasetForward(equityDataTK,volVec(1,eqIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    ratesDataTKd = extendDatasetForward(ratesDataTK,volVec(1,rtIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    comdtyDataTKd = extendDatasetForward(comdtyDataTK,volVec(1,cmIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    ccyDataTKd = extendDatasetForward(ccyDataTK,volVec(1,cyIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
   
    volVec = (diag(squeeze(covmtxLN(:,:,end))).^.5)';
    assetDataLNu = extendDatasetForward(assetDataLN,volVec,noPeriods,grossPerturbation); 
    equityDataLNu = extendDatasetForward(equityDataLN,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ratesDataLNu = extendDatasetForward(ratesDataLN,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    comdtyDataLNu = extendDatasetForward(comdtyDataLN,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ccyDataLNu = extendDatasetForward(ccyDataLN,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    assetDataLNd = extendDatasetForward(assetDataLN,volVec,noPeriods,-grossPerturbation); 
    equityDataLNd = extendDatasetForward(equityDataLN,volVec(1,eqIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    ratesDataLNd = extendDatasetForward(ratesDataLN,volVec(1,rtIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    comdtyDataLNd = extendDatasetForward(comdtyDataLN,volVec(1,cmIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
    ccyDataLNd = extendDatasetForward(ccyDataLN,volVec(1,cyIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 

    volVec = (diag(squeeze(covmtxNY(:,:,end))).^.5)';
    assetDataNYu = extendDatasetForward(assetDataNY,volVec,noPeriods,grossPerturbation); 
    equityDataNYu = extendDatasetForward(equityDataNY,volVec(1,eqIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ratesDataNYu = extendDatasetForward(ratesDataNY,volVec(1,rtIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    comdtyDataNYu = extendDatasetForward(comdtyDataNY,volVec(1,cmIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    ccyDataNYu = extendDatasetForward(ccyDataNY,volVec(1,cyIndx),noPeriods,grossPerturbation); %#ok<NASGU> 
    assetDataNYd = extendDatasetForward(assetDataNY,volVec,noPeriods,-grossPerturbation); 
    equityDataNYd = extendDatasetForward(equityDataNY,volVec(1,eqIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
   ratesDataNYd = extendDatasetForward(ratesDataNY,volVec(1,rtIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
   comdtyDataNYd = extendDatasetForward(comdtyDataNY,volVec(1,cmIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
   ccyDataNYd = extendDatasetForward(ccyDataNY,volVec(1,cyIndx),noPeriods,-grossPerturbation); %#ok<NASGU> 
%end

switch executionTZ
   case 'postTokyoClose' 
      assetDataPx = assetDataLN;
      assetDataPxU = assetDataLNu;
      assetDataPxD = assetDataLNd;
   case 'postLondonClose' 
      assetDataPx = assetDataNY;
      assetDataPxU = assetDataNYu;
      assetDataPxD = assetDataNYd;
   case 'postNYClose' 
      assetDataPx = assetDataTK;
      assetDataPxU = assetDataTKu;
      assetDataPxD = assetDataTKd;
end 

timeZones = {'TK','LN','NY'};
switch trendType
%     case 'EXPXO'
%         [signal, ~, portConfig] = calcExpxoSignal(config,dataConfig,portConfig);
%         portSim = constructPortfolioGM3(assetData,signal,covmtx,dataConfig,portConfig);
%         displayPnl(portSim, trendType, verbose);
    case 'MMA'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u']);
           eval(['ratesData = ratesData',timeZones{i},'u']);
           eval(['comdtyData = comdtyData',timeZones{i},'u']); 
           eval(['ccyData = ccyData',timeZones{i},'u']);
           [signal, signalCube, portConfig] = calcMmaSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},'u = signal']); 
           eval(['signalCube',timeZones{i},'u = signalCube']); 
        end % for 
        signalU = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        portSimU = constructPortfolioGM4(assetDataPx,signalU,covmtxExt,datesCovExt,dataConfig,portConfig);
%        displayPnl(portSim, trendType, verbose);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d']);
           eval(['ratesData = ratesData',timeZones{i},'d']);
           eval(['comdtyData = comdtyData',timeZones{i},'d']); 
           eval(['ccyData = ccyData',timeZones{i},'d']);
           [signal, signalCube, portConfig] = calcMmaSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},'d = signal']); 
           eval(['signalCube',timeZones{i},'d = signalCube']); 
        end % for 
        signalU = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        portSimU = constructPortfolioGM4(assetDataPxU,signalU,covmtxExt,datesCovExt,dataConfig,portConfig);
        signalD = combineTZtrendSignals(signalTKd,signalLNu,signalNYu,executionTZ,dataConfig);
        portSimD = constructPortfolioGM4(assetDataPxD,signalD,covmtxExt,datesCovExt,dataConfig,portConfig);
    case 'MBO'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u']);
           eval(['ratesData = ratesData',timeZones{i},'u']);
           eval(['comdtyData = comdtyData',timeZones{i},'u']); 
           eval(['ccyData = ccyData',timeZones{i},'u']);
           [signal, signalCube, portConfig] = calcMboSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},'u = signal']); 
           eval(['signalCube',timeZones{i},'u = signalCube']); 
        end % for 
        signalU = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        portSimU = constructPortfolioGM4(assetDataPxU,signalU,covmtxExt,datesCovExt,dataConfig,portConfig); 
        % displayPnl(portSim, trendType, verbose);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d']);
           eval(['ratesData = ratesData',timeZones{i},'d']);
           eval(['comdtyData = comdtyData',timeZones{i},'d']); 
           eval(['ccyData = ccyData',timeZones{i},'d']);
           [signal, signalCube, portConfig] = calcMboSignal(config,dataConfig,portConfig); %#ok<ASGLU>
           eval(['signal',timeZones{i},'d = signal']); 
           eval(['signalCube',timeZones{i},'d = signalCube']); 
        end % for 
        signalD = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        portSimD = constructPortfolioGM4(assetDataPxD,signalD,covmtxExt,datesCovExt,dataConfig,portConfig);
    case 'MMO'
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u']);
           eval(['ratesData = ratesData',timeZones{i},'u']);
           eval(['comdtyData = comdtyData',timeZones{i},'u']); 
           eval(['ccyData = ccyData',timeZones{i},'u']);
           [signal, signalCube, portConfig] = calcMmoSignal(config,dataConfig,portConfig,timeZones{i}); %#ok<ASGLU>
           eval(['signal',timeZones{i},'u = signal;']); 
           eval(['signalCube',timeZones{i},'u = signalCube;']); 
        end % for 
        signalU = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        portSimU = constructPortfolioGM4(assetDataPxU,signalU,covmtxExt,datesCovExt,dataConfig,portConfig); 
        % displayPnl(portSim, trendType, verbose);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d']);
           eval(['ratesData = ratesData',timeZones{i},'d']);
           eval(['comdtyData = comdtyData',timeZones{i},'d']); 
           eval(['ccyData = ccyData',timeZones{i},'d']);
           [signal, signalCube, portConfig] = calcMmoSignal(config,dataConfig,portConfig,timeZones{i}); %#ok<ASGLU>
           eval(['signal',timeZones{i},'d = signal;']); 
           eval(['signalCube',timeZones{i},'d = signalCube;']); 
        end % for 
        signalD = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        portSimD = constructPortfolioGM4(assetDataPxD,signalD,covmtxExt,datesCovExt,dataConfig,portConfig); 
    case 'TSTAT'
        spliceDatesTimeZones= nan(1,length(timeZones));
%         for i = 1:length(timeZones)
%            eval(['equityData = equityData',timeZones{i},'u']);
%            eval(['ratesData = ratesData',timeZones{i},'u']);
%            eval(['comdtyData = comdtyData',timeZones{i},'u']); 
%            eval(['ccyData = ccyData',timeZones{i},'u']);
%            try 
%                if ~config.tstat.spliceOption
%                    disp('spliceOption is false for tstat, refreshing tstat structure! '); 
%                    error ('spliceOption is false for tstat, refreshing tstat structure!')
%                end 
%                eval(['load ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw ;'])
%                dates0= zeros (length (signal.subStrat),1);
%                for j =1:length (signal.subStrat)
%                     dates0(j) =  signal.subStrat(j).dates(end); 
%                end 
%                date0 = floor(busdate(min(dates0)-config.tstat.spliceBusdays)); 
%                spliceDatesTimeZones(i)= date0; 
%                [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignal(config,dataConfig,portConfig, date0, timeZones{i}); 
%                signal = spliceSignalStruct( signal, signalNew ,date0   );   
%                signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
%                tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
%            catch
%                spliceDatesTimeZones(i) = nan;
%                [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
%            end 
%            eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
%            eval(['signal',timeZones{i},' = signal;']); 
%            eval(['signalCube',timeZones{i},' = signalCube;']); 
%            eval(['tstatCubeRaw',timeZones{i},' = tstatCubeRaw;']); 
%         end % for 
%         storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
%         signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
%         portSim = constructPortfolioGM4(assetDataPx,signal,covmtx,datesCov,dataConfig,portConfig); 
%         portSim.totTC=   nansum(portSim.tc, 2);
%         displayPnl(portSim, trendType, verbose);
    case 'Combined'
        disp([' Running MMA singals: ', datestr(datetime())]);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal, signalCube, portConfig] = calcMmaSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},' = signal;']);
           eval(['signalCube',timeZones{i},' = signalCube;']);
        end % for 
        signalMMA = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        %portSimMMA = constructPortfolioGM4(assetDataPx,signalMMA,covmtxExt,datesCovExt,dataConfig,portConfig);
        
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u',';']);
           eval(['ratesData = ratesData',timeZones{i},'u',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'u',';']); 
           eval(['ccyData = ccyData',timeZones{i},'u',';']);
           [signal, signalCube, portConfig] = calcMmaSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},'u = signal;']);
           eval(['signalCube',timeZones{i},'u = signalCube;']);
        end % for 
        signalMMAu = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        %portSimMMAu = constructPortfolioGM4(assetDataPxU,signalMMAu,covmtxExt,datesCovExt,dataConfig,portConfig);
        
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d',';']);
           eval(['ratesData = ratesData',timeZones{i},'d',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'d',';']); 
           eval(['ccyData = ccyData',timeZones{i},'d',';']);
           [signal, signalCube, portConfig] = calcMmaSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},'d = signal;']);
           eval(['signalCube',timeZones{i},'d = signalCube;']);
        end % for 
        signalMMAd = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        %portSimMMAd = constructPortfolioGM4(assetDataPxD,signalMMAd,covmtxExt,datesCovExt,dataConfig,portConfig);        
        disp([' Finished MMA singals: ', datestr(datetime())]);
%         displayPnl(portSimMMA, 'MMA', verbose);
% Now MBO:
        disp([' Running MBO singals: ', datestr(datetime())]);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal,signalCube, portConfig] = calcMboSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},' = signal;']); 
           eval(['signalCube',timeZones{i},' = signalCube;']); 
        end % for 
        signalMBO = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        %portSimMBO = constructPortfolioGM4(assetDataPx,signalMBO,covmtxExt,datesCovExt,dataConfig,portConfig);
        
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u',';']);
           eval(['ratesData = ratesData',timeZones{i},'u',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'u',';']); 
           eval(['ccyData = ccyData',timeZones{i},'u',';']);
           [signal,signalCube, portConfig] = calcMboSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},'u = signal;']);
           eval(['signalCube',timeZones{i},'u = signalCube;']);
        end % for 
        signalMBOu = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        %portSimMBOu = constructPortfolioGM4(assetDataPxU,signalMBOu,covmtxExt,datesCovExt,dataConfig,portConfig);
        
%         displayPnl(portSimMBO, 'MBO', verbose);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d',';']);
           eval(['ratesData = ratesData',timeZones{i},'d',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'d',';']); 
           eval(['ccyData = ccyData',timeZones{i},'d',';']);
           [signal,signalCube, portConfig] = calcMboSignalfwd(config,dataConfig,portConfig); 
           eval(['signal',timeZones{i},'d = signal;']);
           eval(['signalCube',timeZones{i},'d = signalCube;']);
        end % for 
        signalMBOd = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        %portSimMBOd = constructPortfolioGM4(assetDataPxD,signalMBOd,covmtxExt,datesCovExt,dataConfig,portConfig);
        disp([' Finished MBO singals: ', datestr(datetime())]);
        
        % MMO
        disp([' Running MMO singals: ', datestr(datetime())]);
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},';']);
           eval(['ratesData = ratesData',timeZones{i},';']);
           eval(['comdtyData = comdtyData',timeZones{i},';']); 
           eval(['ccyData = ccyData',timeZones{i},';']);
           [signal, ~, portConfig] = calcMmoSignalfwd(config,dataConfig,portConfig,timeZones{i});
           eval(['signal',timeZones{i},' = signal;']); 
        end % for 
        signalMMO = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        %portSimMMO = constructPortfolioGM4(assetDataPx,signalMMO,covmtxExt,datesCovExt,dataConfig,portConfig);

        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u',';']);
           eval(['ratesData = ratesData',timeZones{i},'u',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'u',';']); 
           eval(['ccyData = ccyData',timeZones{i},'u',';']);
           [signal, ~, portConfig] = calcMmoSignalfwd(config,dataConfig,portConfig,timeZones{i});
           eval(['signal',timeZones{i},'u = signal;']); 
        end % for 
        signalMMOu = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        %portSimMMOu = constructPortfolioGM4(assetDataPxU,signalMMOu,covmtxExt,datesCovExt,dataConfig,portConfig);

        spliceDatesTimeZones= nan(1,length(timeZones));
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d',';']);
           eval(['ratesData = ratesData',timeZones{i},'d',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'d',';']); 
           eval(['ccyData = ccyData',timeZones{i},'d',';']);
           [signal, ~, portConfig] = calcMmoSignalfwd(config,dataConfig,portConfig,timeZones{i});
           eval(['signal',timeZones{i},'d = signal;']); 
        end % for 
        signalMMOd = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        %portSimMMOd = constructPortfolioGM4(assetDataPxD,signalMMOd,covmtxExt,datesCovExt,dataConfig,portConfig);
        disp([' Finished MMO singals: ', datestr(datetime())]);
        
        % TSTAT
        disp([' Running TSTAT singals: ', datestr(datetime())]);
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
               [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignalfwd(config,dataConfig,portConfig, date0, timeZones{i}); 
               signal = spliceSignalStruct( signal, signalNew ,date0   );   
               signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
               tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
           catch
               spliceDatesTimeZones(i) = nan; 
               [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
           end 
           % eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
           eval(['signal',timeZones{i},' = signal;']); 
           eval(['signalCube',timeZones{i},' = signalCube;']); 
           eval(['tstatCubeRaw',timeZones{i},' = tstatCubeRaw;']); 
        end % for 
        %storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
        signalTSTAT = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig);
        %portSimTSTAT = constructPortfolioGM4(assetDataPx,signalTSTAT,covmtxExt,datesCovExt,dataConfig,portConfig); 
        %portSimTSTAT.totTC = nansum(portSimTSTAT.tc,2);

        spliceDatesTimeZones= nan(1,length(timeZones));
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'u',';']);
           eval(['ratesData = ratesData',timeZones{i},'u',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'u',';']); 
           eval(['ccyData = ccyData',timeZones{i},'u',';']);
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
               [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignalfwd(config,dataConfig,portConfig, date0, timeZones{i}); 
               signal = spliceSignalStruct( signal, signalNew ,date0   );   
               signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
               tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
           catch
               spliceDatesTimeZones(i) = nan; 
               [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
           end 
           % eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
           eval(['signal',timeZones{i},'u = signal;']); 
           eval(['signalCube',timeZones{i},'u = signalCube;']); 
           eval(['tstatCubeRaw',timeZones{i},'u = tstatCubeRaw;']); 
        end % for 
        %storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
        signalTSTATu = combineTZtrendSignals(signalTKu,signalLNu,signalNYu,executionTZ,dataConfig);
        %portSimTSTATu = constructPortfolioGM4(assetDataPxU,signalTSTATu,covmtxExt,datesCovExt,dataConfig,portConfig); 
        %portSimTSTATu.totTC = nansum(portSimTSTATu.tc, 2);

        spliceDatesTimeZones= nan(1,length(timeZones));
        for i = 1:length(timeZones)
           eval(['equityData = equityData',timeZones{i},'d',';']);
           eval(['ratesData = ratesData',timeZones{i},'d',';']);
           eval(['comdtyData = comdtyData',timeZones{i},'d',';']); 
           eval(['ccyData = ccyData',timeZones{i},'d',';']);
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
               [signalNew,  portConfig, signalCubeNew,  tstatCubeRawNew] = calcTstatSignalfwd(config,dataConfig,portConfig, date0, timeZones{i}); 
               signal = spliceSignalStruct( signal, signalNew ,date0   );   
               signalCube = spliceSignalStruct( signalCube, signalCubeNew ,date0   );   
               tstatCubeRaw = spliceSignalStruct( tstatCubeRaw, tstatCubeRawNew ,date0   );   
           catch
               spliceDatesTimeZones(i) = nan; 
               [signal, portConfig, signalCube,tstatCubeRaw] = calcTstatSignal(config,dataConfig,portConfig , nan, timeZones{i}); 
           end 
           % eval(['save ',config.signalOutputPath,'output\tstat\TSTATtrendCache' , timeZones{i},'.mat signal signalCube tstatCubeRaw;'])
           eval(['signal',timeZones{i},'d = signal;']); 
           eval(['signalCube',timeZones{i},'d = signalCube;']); 
           eval(['tstatCubeRaw',timeZones{i},'d = tstatCubeRaw;']); 
        end % for 
        %storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN, tstatCubeRawNY , spliceDatesTimeZones   )
        signalTSTATd = combineTZtrendSignals(signalTKd,signalLNd,signalNYd,executionTZ,dataConfig);
        %portSimTSTATd = constructPortfolioGM4(assetDataPxD,signalTSTATd,covmtxExt,datesCovExt,dataConfig,portConfig); 
        %portSimTSTATd.totTC = nansum(portSimTSTATd.tc, 2);
        disp([' Fininshed TSTAT singals: ', datestr(datetime())]);
        
        % blend signal prior to port const... more or less the same:
        disp([' Base Case Portfolio Construction: ', datestr(datetime())]);
        signalAll = combineTrendSignals(signalMMA,signalMBO,signalMMO,signalTSTAT,[],[0.25,0.25,0.25,0.25]);
        portSimAll = constructPortfolioGM4(assetDataPx,signalAll,covmtxExt,datesCovExt,dataConfig,portConfig);
        disp([' Up Case Portfolio Construction: ', datestr(datetime())]);
        signalAllu = combineTrendSignals(signalMMAu,signalMBOu,signalMMOu,signalTSTATu,[],[0.25,0.25,0.25,0.25]);
        portSimAllu = constructPortfolioGM4(assetDataPxU,signalAllu,covmtxExt,datesCovExt,dataConfig,portConfig);
        disp([' Down Case Portfolio Construction: ', datestr(datetime())]);
        signalAlld = combineTrendSignals(signalMMAd,signalMBOd,signalMMOd,signalTSTATd,[],[0.25,0.25,0.25,0.25]);
        portSimAlld = constructPortfolioGM4(assetDataPxD,signalAlld,covmtxExt,datesCovExt,dataConfig,portConfig);

%         portSim = portSimAll;
%         portSim = computeTrades(portSim, portSimMMA, portSimMBO, portSimMMO,portSimTSTAT, dataConfig);
%         if verbose
%            portConfig.rebalTol = (1./(16*nanstd(assetDataPx.close)))*(15000/25000000); 
%            portSimAll = constructPortfolioGM4(assetDataPx,signalAll,covmtx,datesCov,dataConfig,portConfig);
%            portSimAll.turnover = (260)*sum(abs(portSimAll.wts(2:end,:)-portSimAll.wts(1:end-1,:)),2);
%            plot(portSimAll.dates(2:end,:),ma(portSimAll.turnover,10)); datetick('x','mmmyy'); grid; title('2-wk annualized turnover')
%            displayPnl(portSimAll, trendType, verbose);
%            % [labels,stats]=displayPnLstatTable(portSim);
%         end % if
    otherwise
        warning('Unexpected trend type.');
end % switch

%if isfield(ctx.conf,'forwardPosn') && ctx.conf.forwardPosn
   tT1 = find(floor(portSimAlld.dates)<=floor(assetDataPxD.endDates0(1)),1,'last');
   scale = portSimAlld.wts(tT1,:)./portSimAlld.rawSig(tT1,:); 
   downSigChg = portSimAlld.rawSig(end,:) - portSimAlld.rawSig(tT1,:); 
   upSigChg = portSimAllu.rawSig(end,:) - portSimAllu.rawSig(tT1,:);  
   downTrade = downSigChg.*scale; 
   upTrade = upSigChg.*scale;  
   volVec = (diag(squeeze(covmtxLN(:,:,end))).^.5)';
   tmpVar = [portSimAlld.wts(tT1,:); upTrade; downTrade; portSimAlld.rawSig(tT1,:); upSigChg; downSigChg; sqrt(5)*volVec]; 
   portSimAllu.names = portSimAllu.header; 
   for i = 1:length(portSimAllu.header) 
       tmpStr = {portSimAllu.header{i}(1:2)};
       if strcmp(tmpStr,'fx')
          tmpStr = {portSimAllu.header{i}(4:end)}; 
       else
          tmpStr = {portSimAllu.header{i}}; 
       end 
       portSimAllu.names(i) = tmpStr;
   end 
   dataConfig2 = dataConfig; 
   dTemp = busdate(((today()-10):today())'); 
   indx = find(dTemp<=today(),1,'last'); 
   dataConfig2.startDate = dTemp(indx); 
   dataConfig2.endDate = dTemp(indx); 
   currPxData = fetchCurrPxData4trend(dataConfig2,'TK'); 
   tmpVar = [tmpVar;currPxData.close]; 
   clear dataConfig2; 
   varNames = {'currWts','dWtsUP','dWtsDOWN','currSig','chgSigUP','chgSigDOWN','weeklyVol','sigClosePx'}; 
   tblEq = array2table(tmpVar(:,eqIndx)','VariableNames',varNames,'RowNames',portSimAllu.names(:,eqIndx)); 
   tblRt = array2table(tmpVar(:,rtIndx)','VariableNames',varNames,'RowNames',portSimAllu.names(:,rtIndx)); 
   tblCo = array2table(tmpVar(:,cmIndx)','VariableNames',varNames,'RowNames',portSimAllu.names(:,cmIndx)); 
   tblCcy = array2table(tmpVar(:,cyIndx)','VariableNames',varNames,'RowNames',portSimAllu.names(:,cyIndx)); 
   
   disp([' Storing Pertubation Analysis to excel files; Ignore warning signs: ', datestr(datetime())]);
   filenameEq = ['\\gama.com\Singapore\Common\quantProduction\docs\modelDocs\naiveTrend\perturbation\pertubation_',datestr(today,'ddmmmyyyy'),'_eq.csv'];
   writetable(tblEq,filenameEq,'WriteRowNames',true,'Delimiter',',','QuoteStrings',true);
   filenameRt = ['\\gama.com\Singapore\Common\quantProduction\docs\modelDocs\naiveTrend\perturbation\pertubation_',datestr(today,'ddmmmyyyy'),'_rt.csv'];
   writetable(tblRt,filenameRt,'WriteRowNames',true,'Delimiter',',','QuoteStrings',true);
   filenameCm = ['\\gama.com\Singapore\Common\quantProduction\docs\modelDocs\naiveTrend\perturbation\pertubation_',datestr(today,'ddmmmyyyy'),'_cm.csv'];
   writetable(tblCo,filenameCm,'WriteRowNames',true,'Delimiter',',','QuoteStrings',true);
   filenameCcy = ['\\gama.com\Singapore\Common\quantProduction\docs\modelDocs\naiveTrend\perturbation\pertubation_',datestr(today,'ddmmmyyyy'),'_ccy.csv'];
   writetable(tblCcy,filenameCcy,'WriteRowNames',true,'Delimiter',',','QuoteStrings',true);
   disp([' Finished Pertubation Analysis to excel files; Ignore warning signs: ', datestr(datetime())]);
%end % if 
%eval(['save ',config.signalOutputPath,'output\simResults.mat portSim signalAll config dataConfig portConfig;']) 

end % fn
