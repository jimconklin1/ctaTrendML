function [signal , signalCube] = calcBrkOutTrendSignal2(data,config,subStratConfig,fParam,spliceDate)
% Nearly the same as calcBrkOutTrendSignal.m, but selects a subset of
%  assets using the structure subStratConfig.

if nargin >= 5 && ~isempty(spliceDate)
   simStartDate = spliceDate;
else
   simStartDate = config.simStartDate; 
end 

if isfield(config,'trendSignalOption')
   signalOption = config.trendSignalOption; 
else
   signalOption = 1; 
end

% select subset of chosen asset class:
data.header = data.header(:,subStratConfig.indx);
data.close = data.close(:,subStratConfig.indx);
data.range = data.range(:,subStratConfig.indx);
data.values = data.values(:,subStratConfig.indx);
data.timezone = data.timezone(:,subStratConfig.indx);
data.startDates = data.startDates(:,subStratConfig.indx);
data.endDates = data.endDates(:,subStratConfig.indx);

if signalOption == 3
   [signal, ~] = calcBrkOutSigEnhanced(data,fParam,simStartDate); 
else
   [signal, signalCube] = calcBrkOutSig(data,fParam,simStartDate); 
end

% structure output variable: 
signal.assets = signal.assetIDs;
signalCube.assets = signal.assetIDs ; 
% signal.assetIDs = data.header; 
% signal.dates = signal.dates; 
% signal.values = signal.values; 

end % fn