function [signal,  portConfig, signalCube,tstatCubeRaw] = calcTstatSignalfwd(config,dataConfig,portConfig, givendate, TZ ) 
%CALCTSTATSIGNAL Summary of this function goes here
%   Detailed explanation goes here

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
tstatCubeRaw.subStratNames = portConfig.names;
tstatCubeRaw.subStratAssetClass = portConfig.assetClass;
signal.subStratNames = portConfig.names;
signal.subStratAssetClass = portConfig.assetClass;

variableList = portConfig.names;
trendType = 'TSTAT';
for i = 1:length(variableList)
    variableList(i) = {[variableList{i},'_',trendType]};
end

% if isfield(config,'spliceOption') && config.spliceOption
%     spliceOption = config.spliceOption;
%     eval(['load ',config.signalOutputPath,trendType,'trendCache', TZ,'.mat signal config dataConfig;']);
% else
%     spliceOption = false;
% end

% rates tstat
% if spliceOption
%     spliceDate =  signalMArates.dates(end-config.tstat.rates.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(ratesData,config,portConfig,config.tstat.rates.fParam, givendate, TZ);
temp.name = ['trndSig',trendType,'rates'];
temp2.name = ['trndSigCube',trendType,'rates'];
temp4.name = ['trndTstatCubeRaw',trendType,'rates'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);





% equity tstat, DM
% if spliceOption
%     spliceDate =  signalMAequityFast.dates(end-config.tstat.equityDM.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end

[temp,  temp2, temp4] = calcTstatisticSignal(equityData,config,portConfig,config.tstat.equityDM.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'equityDM'];
temp2.name = ['trndSigCube',trendType,'equityDM'];
temp4.name = ['trndTstatCubeRaw',trendType,'equityDM'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);

% equity tstat, EM
% if spliceOption
%     spliceDate =  signalMAequitySlow.dates(end-config.tstat.equityEM.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp, temp2,  temp4] = calcTstatisticSignal(equityData,config,portConfig,config.tstat.equityEM.fParam, givendate, TZ);
temp.name = ['trndSig',trendType,'equityEM'];
temp2.name = ['trndSigCube',trendType,'equityEM'];
temp4.name = ['trndTstatCubeRaw',trendType,'equityEM'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);

% ccy tstat, DM
% if spliceOption
%     spliceDate =  signalMAccyFast.dates(end-config.tstat.ccyDM.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(ccyData,config,portConfig,config.tstat.ccyDM.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'ccyDM'];
temp2.name = ['trndSigCube',trendType,'ccyDM'];
temp4.name = ['trndTstatCubeRaw',trendType,'ccyDM'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);


% ccy tstat, EM
% if spliceOption
%     spliceDate =  signalMAccySlow.dates(end-config.tstat.ccyEM.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(ccyData,config,portConfig,config.tstat.ccyEM.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'ccyEM'];
temp2.name = ['trndSigCube',trendType,'ccyEM'];
temp4.name = ['trndTstatCubeRaw',trendType,'ccyEM'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);


% commodity tstat, energy
% if spliceOption
%     spliceDate =  signalMAequityFast.dates(end-config.tstat.comdtyEnergy.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(comdtyData,config,portConfig,config.tstat.comdtyEnergy.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'comdtyEnergy'];
temp2.name = ['trndSigCube',trendType,'comdtyEnergy'];
temp4.name = ['trndTstatCubeRaw',trendType,'comdtyEnergy'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);


% commodity tstat, metals
% if spliceOption
%     spliceDate =  signalMAequityFast.dates(end-config.tstat.comdtyMetal.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(comdtyData,config,portConfig,config.tstat.comdtyMetal.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'comdtyMetal'];
temp2.name = ['trndSigCube',trendType,'comdtyMetal'];
temp4.name = ['trndTstatCubeRaw',trendType,'comdtyMetal'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);


% commodity tstat, ags
% if spliceOption
%     spliceDate =  signalMAequityFast.dates(end-config.tstat.comdtyAgs.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(comdtyData,config,portConfig,config.tstat.comdtyAgs.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'comdtyAgs'];
temp2.name = ['trndSigCube',trendType,'comdtyAgs'];
temp4.name = ['trndTstatCubeRaw',trendType,'comdtyAgs'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
eval([temp2.name,' = temp2;']);



% short rates tstat
% if spliceOption
%     spliceDate =  signalMArates.dates(end-config.tstat.shortRates.fParam.volHL-1,:);
% else
%     spliceDate = [];
% end
[temp,  temp2,  temp4] = calcTstatisticSignal(ratesData,config,portConfig,config.tstat.shortRates.fParam, givendate, TZ); 
temp.name = ['trndSig',trendType,'shortRates'];
temp2.name = ['trndSigCube',trendType,'shortRates'];
temp4.name = ['trndTstatCubeRaw',trendType,'shortRates'];
eval([temp4.name,' = temp4;']);
eval([temp.name,' = temp;']);
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





tstatCubeRaw.variableList = variableList;
eval(['tstatCubeRaw.subStrat(1) = trndTstatCubeRaw',trendType,'rates;']);
eval(['tstatCubeRaw.subStrat(2) = trndTstatCubeRaw',trendType,'equityDM;']);
eval(['tstatCubeRaw.subStrat(3) = trndTstatCubeRaw',trendType,'equityEM;']);
eval(['tstatCubeRaw.subStrat(4) = trndTstatCubeRaw',trendType,'ccyDM;']);
eval(['tstatCubeRaw.subStrat(5) = trndTstatCubeRaw',trendType,'ccyEM;']);
eval(['tstatCubeRaw.subStrat(6) = trndTstatCubeRaw',trendType,'comdtyEnergy;']);
eval(['tstatCubeRaw.subStrat(7) = trndTstatCubeRaw',trendType,'comdtyMetal;']);
eval(['tstatCubeRaw.subStrat(8) = trndTstatCubeRaw',trendType,'comdtyAgs;']);
eval(['tstatCubeRaw.subStrat(9) = trndTstatCubeRaw',trendType,'shortRates;']);

%eval(['save ',config.signalOutputPath,trendType,'trendCache', TZ,'.mat signal  portConfig  signalCube tstatCubeRaw ;']);

end