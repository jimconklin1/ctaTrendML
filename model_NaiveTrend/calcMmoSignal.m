function [signal, signalCube, portConfig] = calcMmoSignal(config,dataConfig,portConfig, TZ )

if strcmpi(dataConfig.assetUniv(1:3),'all')||strcmpi(dataConfig.assetUniv,'combined')
    equityData = evalin('caller','equityData');
    ratesData = evalin('caller','ratesData');
    ccyData = evalin('caller','ccyData');
    comdtyData = evalin('caller','comdtyData');
    % normalize field name:
    equityData.values = equityData.close;
    ratesData.values = ratesData.close;
    ccyData.values = ccyData.close;
    comdtyData.values = comdtyData.close;
elseif  strcmpi(dataConfig.assetUniv,'futures')
    equityData = evalin('caller','equityData');
    ratesData = evalin('caller','ratesData');
    comdtyData = evalin('caller','comdtyData');
    equityData.values = equityData.close;
    ratesData.values = ratesData.close;
    comdtyData.values = comdtyData.close;
end

signalCube.subStratNames = portConfig.names;
signalCube.subStratAssetClass = portConfig.assetClass;
signal.subStratNames = portConfig.names;
signal.subStratAssetClass = portConfig.assetClass;
%auxCalcs = NaN;
variableList = portConfig.names;
trendType = 'MMO';
for i = 1:length(variableList)
    variableList(i) = {[variableList{i},'_',trendType]};
end

if isfield(config,'spliceOption') && config.spliceOption
    spliceOption = config.spliceOption;
    eval(['load ',config.signalOutputPath,trendType,'trendCache', TZ,'.mat signal config dataConfig;']);
else
    spliceOption = false;
end


% rates MMO
if spliceOption
    spliceDate =  signalMArates.dates(end-config.mmo.rates.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(ratesData,config,dataConfig,portConfig,config.mmo.rates.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'rates'];
tempSignalCube.name = ['trndSigCube',trendType,'rates'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);

% equity MMO, DM
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mmo.equityDM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(equityData,config,dataConfig,portConfig,config.mmo.equityDM.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'equityDM'];
tempSignalCube.name = ['trndSigCube',trendType,'equityDM'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);

% equity MMO, EM
if spliceOption
    spliceDate =  signalMAequitySlow.dates(end-config.mmo.equityEM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(equityData,config,dataConfig,portConfig,config.mmo.equityEM.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'equityEM'];
tempSignalCube.name = ['trndSigCube',trendType,'equityEM'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);

% ccy MMO, DM
if spliceOption
    spliceDate =  signalMAccyFast.dates(end-config.mmo.ccyDM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(ccyData,config,dataConfig,portConfig,config.mmo.ccyDM.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'ccyDM'];
tempSignalCube.name = ['trndSigCube',trendType,'ccyDM'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);

% ccy MMO, EM
if spliceOption
    spliceDate =  signalMAccySlow.dates(end-config.mmo.ccyEM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(ccyData,config,dataConfig,portConfig,config.mmo.ccyEM.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'ccyEM'];
tempSignalCube.name = ['trndSigCube',trendType,'ccyEM'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);


% commodity MMO, energy
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mmo.comdtyEnergy.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(comdtyData,config,dataConfig,portConfig,config.mmo.comdtyEnergy.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'comdtyEnergy'];
tempSignalCube.name = ['trndSigCube',trendType,'comdtyEnergy'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);


% commodity MMO, metals
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mmo.comdtyMetal.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(comdtyData,config,dataConfig,portConfig,config.mmo.comdtyMetal.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'comdtyMetal'];
tempSignalCube.name = ['trndSigCube',trendType,'comdtyMetal'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);



% commodity MMO, ags
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mmo.comdtyAgs.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(comdtyData,config,dataConfig,portConfig,config.mmo.comdtyAgs.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'comdtyAgs'];
tempSignalCube.name = ['trndSigCube',trendType,'comdtyAgs'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);

% short rates MMO
if spliceOption
    spliceDate =  signalMArates.dates(end-config.mmo.shortRates.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, tempSignalCube] = calcMomentumSignal(ratesData,config,dataConfig,portConfig,config.mmo.shortRates.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'shortRates'];
tempSignalCube.name = ['trndSigCube',trendType,'shortRates'];
eval([temp.name,' = temp;']);
eval([tempSignalCube.name,' = tempSignalCube;']);


% Assign structure:
signal.variableList = variableList;
eval(['signal.subStrat(1) = trndSig',trendType,'rates;']);
eval(['signal.subStrat(2) = trndSig',trendType,'equityDM;']);
eval(['signal.subStrat(3) = trndSig',trendType,'equityEM;']);
eval(['signal.subStrat(4) = trndSig',trendType,'ccyDM;']);
eval(['signal.subStrat(5) = trndSig',trendType,'ccyEM;']);
eval(['signal.subStrat(6) = trndSig',trendType,'comdtyEnergy;']);
eval(['signal.subStrat(7) = trndSig',trendType,'comdtyMetal;']);
eval(['signal.subStrat(8) = trndSig',trendType,'comdtyAgs;']);
eval(['signal.subStrat(9) = trndSig',trendType,'shortRates;']);


% Assign structure:
signalCube.variableList = variableList;
eval(['signalCube.subStrat(1) = trndSigCube',trendType,'rates;']);
eval(['signalCube.subStrat(2) = trndSigCube',trendType,'equityDM;']);
eval(['signalCube.subStrat(3) = trndSigCube',trendType,'equityEM;']);
eval(['signalCube.subStrat(4) = trndSigCube',trendType,'ccyDM;']);
eval(['signalCube.subStrat(5) = trndSigCube',trendType,'ccyEM;']);
eval(['signalCube.subStrat(6) = trndSigCube',trendType,'comdtyEnergy;']);
eval(['signalCube.subStrat(7) = trndSigCube',trendType,'comdtyMetal;']);
eval(['signalCube.subStrat(8) = trndSigCube',trendType,'comdtyAgs;']);
eval(['signalCube.subStrat(9) = trndSigCube',trendType,'shortRates;']);

eval(['save ',config.signalOutputPath,trendType,'trendCache', TZ,'.mat signal config dataConfig;']);


end