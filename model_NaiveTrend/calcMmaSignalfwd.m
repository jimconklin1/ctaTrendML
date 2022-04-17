function [signal, signalCube, portConfig] = calcMmaSignalfwd(config,dataConfig,portConfig)

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

signal.subStratNames = portConfig.names;
signal.subStratAssetClass = portConfig.assetClass;
signalCube.subStratNames = portConfig.names;
signalCube.subStratAssetClass = portConfig.assetClass;

variableList = portConfig.names;
trendType = 'MMA';
for i = 1:length(variableList)
    variableList(i) = {[variableList{i},'_',trendType]};
end

if isfield(config,'spliceOption') && config.spliceOption
    spliceOption = config.spliceOption;
    eval(['load ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);
else
    spliceOption = false;
end

% rates MMA
if spliceOption
    spliceDate =  signalMArates.dates(end-config.mma.rates.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(ratesData,config,dataConfig,portConfig,config.mma.rates.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'rates'];
temp2.name = ['trndSigCube',trendType,'rates'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% equity MMA, DM
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mma.equityDM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(equityData,config,dataConfig,portConfig,config.mma.equityDM.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'equityDM'];
eval([temp.name,' = temp;']);
temp2.name = ['trndSigCube',trendType,'equityDM'];
eval([temp2.name,' = temp2;']);

% equity MMA, EM
if spliceOption
    spliceDate =  signalMAequitySlow.dates(end-config.mma.equityEM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(equityData,config,dataConfig,portConfig,config.mma.equityEM.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'equityEM'];
eval(['trndSig',trendType,'equityEM = temp;']);
temp2.name = ['trndSigCube',trendType,'equityEM'];
eval([temp2.name,' = temp2;']);

% ccy MMA, DM
if spliceOption
    spliceDate =  signalMAccyFast.dates(end-config.mma.ccyDM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(ccyData,config,dataConfig,portConfig,config.mma.ccyDM.fParam,spliceDate); 
temp.name = 'ccyDM';
eval(['trndSig',trendType,'ccyDM = temp;']);
temp2.name = ['trndSigCube',trendType,'ccyDM'];
eval([temp2.name,' = temp2;']);

% ccy MMA, EM
if spliceOption
    spliceDate =  signalMAccySlow.dates(end-config.mma.ccyEM.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(ccyData,config,dataConfig,portConfig,config.mma.ccyEM.fParam,spliceDate); 
temp.name = 'ccyEM';
eval(['trndSig',trendType,'ccyEM = temp;']);
temp2.name = ['trndSigCube',trendType,'ccyEM'];
eval([temp2.name,' = temp2;']);

% commodity MMA, energy
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mma.comdtyEnergy.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(comdtyData,config,dataConfig,portConfig,config.mma.comdtyEnergy.fParam,spliceDate); 
temp.name = 'comdtyEnergy';
eval(['trndSig',trendType,'comdtyEnergy = temp;']);
temp2.name = ['trndSigCube',trendType,'comdtyEnergy'];
eval([temp2.name,' = temp2;']);

% commodity MMA, metals
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mma.comdtyMetal.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(comdtyData,config,dataConfig,portConfig,config.mma.comdtyMetal.fParam,spliceDate); 
temp.name = 'comdtyMetal';
eval(['trndSig',trendType,'comdtyMetal = temp;']);
temp2.name = ['trndSigCube',trendType,'comdtyMetal'];
eval([temp2.name,' = temp2;']);

% commodity MMA, ags
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-config.mma.comdtyAgs.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(comdtyData,config,dataConfig,portConfig,config.mma.comdtyAgs.fParam,spliceDate); 
temp.name = 'comdtyAgs';
eval(['trndSig',trendType,'comdtyAgs = temp;']);
temp2.name = ['trndSigCube',trendType,'comdtyAgs'];
eval([temp2.name,' = temp2;']);

% short rates MMA
if spliceOption
    spliceDate = signalMArates.dates(end-config.mma.shortRates.fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp,  temp2] = calcMMATrendSignal2(ratesData,config,dataConfig,portConfig,config.mma.shortRates.fParam,spliceDate);
temp.name = 'shortRates';
eval(['trndSig', trendType, 'shortRates = temp;']);
temp2.name = ['trndSigCube',trendType,'shortRates'];
eval([temp2.name,' = temp2;']);


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

if ~isdeployed
   %eval(['save ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);
end 

end