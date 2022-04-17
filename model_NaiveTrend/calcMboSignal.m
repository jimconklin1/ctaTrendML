function [signal, signalCube, portConfig] = calcMboSignal(config,dataConfig,portConfig)

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
% auxCalcs = NaN;
variableList = portConfig.names;
trendType = 'MBO';
for i = 1:length(variableList)
    variableList(i) = {[variableList{i},'_',trendType]};
end

if isfield(config,'spliceOption') && config.spliceOption
    spliceOption = config.spliceOption;
    eval(['load ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);
else
    spliceOption = false;
end

% rates:
if spliceOption
    spliceDate = signalBOratesFast.dates(end-config.mbo.rates.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(1);
[temp, temp2 ]= calcBrkOutTrendSignal2(ratesData,config,subConfig,config.mbo.rates.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'rates'];
temp2.name = ['trndSigCube',trendType,'rates'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% equities DM:
if spliceOption
    spliceDate =  signalBOratesSlow.dates(end-config.mbo.equitydm.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(2);
[temp, temp2 ] = calcBrkOutTrendSignal2(equityData,config,subConfig,config.mbo.equitydm.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'equityDM'];
temp2.name = ['trndSigCube',trendType,'equityDM'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% equities break-out EM:
if spliceOption
    spliceDate =  signalBOequityFast.dates(end-config.mbo.equityem.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(3);
[temp, temp2 ] = calcBrkOutTrendSignal2(equityData,config,subConfig,config.mbo.equityem.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'equityEM'];
temp2.name = ['trndSigCube',trendType,'equityEM'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% ccy DM:
if spliceOption
    spliceDate = signalBOccyFast.dates(end-config.mbo.ccydm.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(4);
[temp, temp2 ] = calcBrkOutTrendSignal2(ccyData,config,subConfig,config.mbo.ccydm.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'ccyDM'];
temp2.name = ['trndSigCube',trendType,'ccyDM'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);
% ccy EM:
if spliceOption
    spliceDate = signalBOccyFast.dates(end-config.mbo.ccyem.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(5);
[temp, temp2 ] = calcBrkOutTrendSignal2(ccyData,config,subConfig,config.mbo.ccyem.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'ccyEM'];
temp2.name = ['trndSigCube',trendType,'ccyEM'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);
% commodities energy:
if spliceOption
    spliceDate =  signalBOccySlow.dates(end-config.mbo.comdtyEnergy.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(6);
[temp, temp2 ] = calcBrkOutTrendSignal2(comdtyData,config,subConfig,config.mbo.comdtyEnergy.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'comdtyEnergy'];
temp2.name = ['trndSigCube',trendType,'comdtyEnergy'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% commodities metals:
if spliceOption
    spliceDate =  signalBOcomdtyFast.dates(end-config.mbo.comdtyMetal.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(7);
[temp, temp2 ] = calcBrkOutTrendSignal2(comdtyData,config,subConfig,config.mbo.comdtyMetal.fParam,spliceDate);  
temp.name = ['trndSig',trendType,'comdtyMetal'];
temp2.name = ['trndSigCube',trendType,'comdtyMetal'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% commodities ags:
if spliceOption
    spliceDate =  signalBOcomdtySlow.dates(end-config.mbo.comdtyAgs.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(8);
[temp, temp2 ] = calcBrkOutTrendSignal2(comdtyData,config,subConfig,config.mbo.comdtyAgs.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'comdtyAgs'];
temp2.name = ['trndSigCube',trendType,'comdtyAgs'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

% short rates
if spliceOption
    spliceDate = signalBOratesFast.dates(end-config.mbo.shortRates.fParam.volHL-1,:);
else
    spliceDate = [];
end
subConfig = portConfig.subStrat(9);
[temp, temp2 ] = calcBrkOutTrendSignal2(ratesData,config,subConfig,config.mbo.shortRates.fParam,spliceDate); 
temp.name = ['trndSig',trendType,'shortRates'];
temp2.name = ['trndSigCube',trendType,'shortRates'];
eval([temp2.name,' = temp2;']);
eval([temp.name,' = temp;']);

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

eval(['save ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);

end