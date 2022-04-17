function [signal, auxCalcs] = calcExpoXOTrendSignal(data,config,dataConfig,portConfig,params,spliceDate) %#ok
% calcMMATrendSignal2 is nearly identical to calcMMATrendSignal.m except
% that it assigns  subConfig = portConfig.subStrat(fParam.subStrategyNum);

if nargin < 5 || isempty(params)
   params.subStrategyNum = 1;
   params.HL1 = [5,10,20];
   params.HL2 = [10,30,100];
end 

if nargin >= 6 && ~isempty(spliceDate)
   simStartDate = spliceDate; %#ok<NASGU>
else
   simStartDate = config.simStartDate;  %#ok<NASGU>
end 

% if isfield(config,'trendSignalOption')
%    signalOption = config.trendSignalOption; 
% else
%    signalOption = 1; 
% end

data2 = startDataTrunc(data,config);

subStratConfig = portConfig.subStrat(params.subStrategyNum); 
% select subset of chosen asset class:
data.header = data.header(:,subStratConfig.indx);
data.close = data.close(:,subStratConfig.indx);
data.range = data.range(:,subStratConfig.indx);
data.values = data.values(:,subStratConfig.indx);
data.timezone = data.timezone(:,subStratConfig.indx);
data.startDates = data.startDates(:,subStratConfig.indx);
data.endDates = data.endDates(:,subStratConfig.indx);

% compute differences of EWA crossovers:
cumValues = calcCum(data.values,1); 
temp1 = calcEWA(cumValues,params.HL1(1),0,true);
temp2 = calcEWA(cumValues,params.HL2(1),0,true);
tempShrt = temp1 - temp2;
temp1 = calcEWA(cumValues,params.HL1(2),0,true);
temp2 = calcEWA(cumValues,params.HL2(2),0,true);
tempMed = temp1 - temp2;
temp1 = calcEWA(cumValues,params.HL1(3),0,true);
temp2 = calcEWA(cumValues,params.HL2(3),0,true);
tempLong = temp1 - temp2;
clear temp1 temp2;
expStruct.header = data.header;
expStruct.dates = data.dates;

expStruct.rawSigShrt = tempShrt;
expStruct.rawSigMed = tempMed;
expStruct.rawSigLong = tempLong;


% Normalize EWA differences to percentiles on a 1-year look back:
T = size(tempShrt,1); 
N = size(tempShrt,2); 
normTrndShrt = zeros(T,N); 
for t = 261:T 
   temp1 = tempShrt(t-260:t,:); 
   for n = 1:N
      temp2 = sort(temp1(:,n)); 
      normTrndShrt(t,n) = find((temp2 <= tempShrt(t,n)), 1, 'last')/260 - 0.5; 
   end % for
end 

normTrndMed = zeros(T,N); 
for t = 261:T
   temp1 = sort(tempMed(t-260:t,:)); 
   for n = 1:N
      temp2 = sort(temp1(:,n)); 
      normTrndMed(t,n) = find( temp2 <= tempMed(t,n), 1, 'last')/260 - 0.5; 
   end % for
end 

normTrndLong = zeros(T,N); 
for t = 261:T
   temp1 = sort(tempLong(t-260:t,:)); 
   for n = 1:N
      temp2 = sort(temp1(:,n)); 
      normTrndLong(t,n) = find( temp2 <= tempLong(t,n), 1, 'last')/260 - 0.5; 
   end % for
end 

signal0 = (normTrndShrt + normTrndMed + normTrndLong)/1.5; % have range be -1 to 1
signal0(isnan(signal0)) = 0; 

% structure output variable: 
t0 = find(data.dates== data2.dates(1));
signal.assetIDs = data.header; 
signal.dates = data.dates(t0:end,:); 
signal.values = signal0(t0:end,:); 
signal.assets = data.header; 
auxCalcs = expStruct; 
end % fn