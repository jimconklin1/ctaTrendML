function [signal, signalCubeStruc] = calcBrkOutSig(data,brkOutParams,startDate)
% calculate mixed Breakout signal
if ~isfield(data,'values')
   if isfield(data,'close')
      data.values = data.close; 
   elseif isfield(data,'returns')
      data.values = data.returns; 
   elseif isfield(data,'rtns')
      data.values = data.rtns; 
   end % if
end % if 
BOwin = brkOutParams.a; 
[T,N] = size(data.values); 
K = length(BOwin); 
rangeMin = zeros(T,N,K); 
rangeMax = zeros(T,N,K); 
rangeMeanLow = zeros(T,N,K); 
rangeMeanHigh = zeros(T,N,K); 
signalCube = zeros(T,N,K);
spot = calcCum(data.values,0); 
t0 = brkOutParams.a+1; 
for k = 1:K 
   for t = t0(k):T 
      rangeMin(t,:,k) = min(spot(t-BOwin(k):t-1,:)); 
      rangeMax(t,:,k) = max(spot(t-BOwin(k):t-1,:)); 
      rangeMeanHigh(t,:,k) = (0.5*rangeMin(t,:,k) + 0.5*rangeMax(t,:,k)); 
      rangeMeanLow(t,:,k) = (0.5*rangeMin(t,:,k) + 0.5*rangeMax(t,:,k)); 
%      rangeMeanHigh(t,:,k) = (rangeMin(t,:,k) + rangeMax(t,:,k)); 
%      rangeMeanLow(t,:,k) = (rangeMin(t,:,k) + rangeMax(t,:,k)); 
      signalCube(t,:,k) = signalCube(t-1,:,k); 
      % get flat from long:
      temp1 = squeeze(signalCube(t-1,:,k)==1) & (spot(t,:) <= rangeMeanHigh(t,:,k)); 
      signalCube(t,temp1,k) = 0; 
      % get flat from short:
      temp1 = squeeze(signalCube(t-1,:,k)==-1) & (spot(t,:) >= rangeMeanLow(t,:,k)); 
      signalCube(t,temp1,k) = 0; 
      % get long:
      temp2 = spot(t,:) >= rangeMax(t,:,k); 
      signalCube(t,temp2,k) = 1; 
      % get short:
      temp2 = spot(t,:) <= rangeMin(t,:,k); 
      signalCube(t,temp2,k) = -1;
      % flat when spot range is zero
      temp2 = rangeMin(t,:,k) == 0 & rangeMax(t,:,k) == 0;
      signalCube(t,temp2,k) = 0;
   end % for t
end % for k

% Combine signals across the k lookback frequencies:
signal0 = zeros(T,N); 
for n = 1:N
   signal0(:,n) = sum(signalCube(:,n,:),3)/K; % sum along k-th dimension 
end 

signal0 (isnan(data.values))= nan; 
for k=1:K
    tempSignalCube = signalCube (:,:,k); 
    tempSignalCube(isnan(data.values)) = nan; 
    signalCube (:,:,k)= tempSignalCube; 
end 
%calcs = NaN; % calcs = vol; 
t0 = find(floor(data.dates)==floor(startDate)); 
if isempty(t0) && startDate < data.dates(1,1)
   t0 = 1;
   disp('WARNING: startDate is less than the first data in data.dates')
elseif isempty(t0)
   % go back and find the first date prior to startDate:
   k = 0;
   startDate2 = floor(startDate); 
   while isempty(t0) && k < 21
      startDate2 = startDate2-1;   
      t0 = find(floor(data.dates)==startDate2); 
      k = k+1; 
   end % while 
   data.dates(t0,1) = floor(startDate) + mod(data.dates(t0,1),1);
end 
tempDates = data.dates(t0:end); 
signal.assetIDs = data.header; 
signal.dates = tempDates;
signal.values = signal0(t0:end,:); 

signalCubeStruc.assetIDs = data.header; 
signalCubeStruc.dates = tempDates;
signalCubeStruc.lookbacks = BOwin;
signalCubeStruc.values = signalCube(t0:end,:,:); 
end % fn
