function [signal, auxCalcs, portConfig] = calcExpxoSignal(config,dataConfig,portConfig)

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
auxCalcs = NaN;
variableList = portConfig.names;
trendType = 'EXPXO';
for i = 1:length(variableList)
    variableList(i) = {[variableList{i},'_',trendType]};
end

if isfield(config,'spliceOption') && config.spliceOption
    spliceOption = config.spliceOption;
    eval(['load ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);
else
    spliceOption = false;
end

% rates EXPXO
fParam.subStrategyNum = 1;
fParam.HL1 = [5,10,20];
fParam.HL2 = [10,30,100];
if spliceOption
    spliceDate =  signalMArates.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsFast] = calcExponXOTrendSignal(ratesData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = ['trndSig',trendType,'rates'];
eval([temp.name,' = temp;']);

% equity EXPXO, DM
fParam.a = 2:2:20; % 2:2:10; % 6:2:30; % 4:2:24; %
fParam.b = [20,25,30,35,40,50,60];
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 2;
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsFast2] = calcExponXOTrendSignal(equityData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = ['trndSig',trendType,'equityDM'];
eval([temp.name,' = temp;']);

% equity MMA, EM
fParam.a = [5,10,15,20,30]; %
fParam.b = 10:2:20;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 3;
if spliceOption
    spliceDate =  signalMAequitySlow.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsSlow] = calcExponXOTrendSignal(equityData,config,dataConfig,portConfig,fParam,spliceDate); %#ok
temp.name = ['trndSig',trendType,'equityEM'];
eval(['trndSig',trendType,'equityEM = temp;']);

% ccy MMA, DM
fParam.a = [5,10,15,20]; % [5,10,15,20,30];
fParam.b = 20:2:36;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 4;
if spliceOption
    spliceDate =  signalMAccyFast.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsFast] = calcExponXOTrendSignal(ccyData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'ccyDM';
eval(['trndSig',trendType,'ccyDM = temp;']);

% ccy MMA, EM
fParam.a = [5,10,15,20];
fParam.b = 10:3:30;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 5;
if spliceOption
    spliceDate =  signalMAccySlow.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsSlow] = calcExponXOTrendSignal(ccyData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'ccyEM';
eval(['trndSig',trendType,'ccyEM = temp;']);

% commodity MMA, energy
fParam.a = 5:5:20;
fParam.b = 8:2:16;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 6;
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsFast] = calcExponXOTrendSignal(comdtyData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'comdtyEnergy';
eval(['trndSig',trendType,'comdtyEnergy = temp;']);

% commodity MMA, metals
fParam.a = 5:5:25;
fParam.b = 7:3:25; %6:2:24;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 7;
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsSlow] = calcExponXOTrendSignal(comdtyData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'comdtyMetal';
eval(['trndSig',trendType,'comdtyMetal = temp;']);

% commodity MMA, ags
fParam.a = 2:3:20;
fParam.b = 12:3:30; %6:2:24;
fParam.volHL = [21,63,260]; % [21,126,520];
fParam.volThresh= [0.0, 0.75];
fParam.subStrategyNum = 8;
if spliceOption
    spliceDate =  signalMAequityFast.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsSlow] = calcExponXOTrendSignal(comdtyData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'comdtyAgs';
eval(['trndSig',trendType,'comdtyAgs = temp;']);

% short rates EXPXO
fParam.HL1 = [5,10,20];
fParam.HL2 = [10,30,100];
fParam.subStrategyNum = 9;
if spliceOption
    spliceDate =  signalMArates.dates(end-fParam.volHL-1,:);
else
    spliceDate = [];
end
[temp, lookbackWtsFast] = calcExponXOTrendSignal(ratesData,config,dataConfig,portConfig,fParam,spliceDate); %#ok<ASGLU>
temp.name = 'shortRates';
eval(['trndSig',trendType,'shortRates = temp;']);

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

eval(['save ',config.signalOutputPath,trendType,'trendCache.mat signal config dataConfig;']);

end