function [signal, signalCube] = calcMMATrendSignal2(data,config,dataConfig,portConfig,fParam,spliceDate) %#ok
% calcMMATrendSignal2 is nearly identical to calcMMATrendSignal.m except
% that it assigns  subConfig = portConfig.subStrat(fParam.subStrategyNum);

if nargin >= 6 && ~isempty(spliceDate)
   simStartDate = spliceDate; %#ok<NASGU>
else
   simStartDate = config.simStartDate;  %#ok<NASGU>
end 

if isfield(config,'trendSignalOption')
   signalOption = config.trendSignalOption; 
else
   signalOption = 1; 
end

data2 = startDataTrunc(data,config);

subStratConfig = portConfig.subStrat(fParam.subStrategyNum); 
% select subset of chosen asset class:
data.header = data.header(:,subStratConfig.indx);
data.close = data.close(:,subStratConfig.indx);
data.range = data.range(:,subStratConfig.indx);
data.values = data.values(:,subStratConfig.indx);
data.timezone = data.timezone(:,subStratConfig.indx);
data.startDates = data.startDates(:,subStratConfig.indx);
data.endDates = data.endDates(:,subStratConfig.indx);

[signal0,temp, signalCube0] = calcMMAsig(data,fParam,signalOption); %  signalOption: 1 = no vol conditioning, 2 = vol conditioned

% structure output variable: 
t0 = find(data.dates== data2.dates(1));
signal.assetIDs = data.header; 
signal.dates = data.dates(t0:end,:); 
signal.values = signal0(t0:end,:); 
signal.assets = data.header; 

signalCube.assetIDs = data.header; 
signalCube.dates = data.dates(t0:end,:); 
signalCube.values = signalCube0(t0:end,:,:); 
signalCube.lookbacks = temp.ma;
signalCube.assets = data.header; 
end % fn