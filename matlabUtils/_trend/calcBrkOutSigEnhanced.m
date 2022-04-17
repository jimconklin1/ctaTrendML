function [signal, vol] = calcBrkOutSigEnhanced(data,brkOutParams,startDate)
% calculate mixed Breakout signal
BOwin = brkOutParams.a;
[T,N] = size(data.values); 
K = length(BOwin); 
dlyVolFloor = 0.0025;
% hl1 = brkOutParams.b(1); 
% hl2 = brkOutParams.b(2); 
% a = brkOutParams.b(3); 
rangeMin = zeros(T,N,K); 
rangeMax = zeros(T,N,K); 
rangeMeanLow = zeros(T,N,K); 
rangeMeanHigh = zeros(T,N,K); 
signalCube = zeros(T,N,K);
rawPnL = signalCube;
rtns = data.values; 
spot = calcCum(data.values,1); 
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
   end % for t
end % for k

% compute different volatility measures for use in filters: 
vol1 = calcEWAvol(rtns,brkOutParams.volHL(1),0,nanstd(rtns(1:130,:)),true,3.5); 
vol2 = calcEWAvol(rtns,brkOutParams.volHL(2),0,nanstd(rtns(1:130,:)),true,3.5); 
vol3 = calcEWAvol(rtns,brkOutParams.volHL(3),0,nanstd(rtns(1:260,:)),true,3.5); 
vol = 0.5*vol1 + 0.5*vol2; 
volSlow = 0.2*vol1 + 0.8*vol3; 
volRank = (vol - volSlow)./volSlow; 
volFilt = zeros(T,N); 
volFilt = volFilt + (volRank>brkOutParams.volThresh(2)) - (volRank<brkOutParams.volThresh(1)); 
vol(isnan(vol)) = dlyVolFloor;

for k = 1:K
   for n = 1:N
       rawPnL(:,n,k) = dlyVolFloor*[0; rtns(2:end,n).*signalCube(1:end-1,n,k)./vol(1:end-1,n)]; 
   end % for n 
end % for k 

SRsig1 = zeros(T,K);
SRsig2 = zeros(T,K);
SRsig3 = zeros(T,K);
srFilt1 = zeros(T,K); 
srFilt2 = zeros(T,K); 
srFilt3 = zeros(T,K); 
srLookback = ones(3,K); 
rtns_k.header = {num2str(k)}; 
rtns_k.dates = data.dates;
for k = 1:K 
   srLookback(1,k) = round((BOwin(1)+BOwin(k))/2); 
   srLookback(2,k) = BOwin(k); % round((126+BOwin(k))/2); 
   srLookback(3,k) = round((BOwin(K)+BOwin(k))/2); 
   rtns_k.values = sum(squeeze(rawPnL(:,:,k)),2); 
   [temp,~] = calcMMSRsig(rtns_k,srLookback(1,k)); SRsig1(:,k) = temp.values;
   [temp,~] = calcMMSRsig(rtns_k,srLookback(2,k)); SRsig2(:,k) = temp.values;
   [temp,~] = calcMMSRsig(rtns_k,srLookback(3,k)); SRsig3(:,k) = temp.values;
   srFilt1(:,k) = ~(SRsig1(:,k)<0); 
   srFilt2(:,k) = ~(SRsig2(:,k)<0); % - (SRsig1(:,k)<0);
   srFilt3(:,k) = ~(SRsig1(:,k)<0 | SRsig2(:,k)<0); % ~(SRsig1(:,k)<0 | SRsig2(:,k)<0);
end 
%srFilt2(srFilt2==0) = -1; 
%srFilt3(srFilt3==0) = -1; 
%k=k+1; plot([calcCum((sum(squeeze(rawPnL(:,:,k)),2)),1),SRsig1(:,k),SRsig2(:,k),(srFilt1(:,k)-2)])

for k = 1:K 
   signalCube(:,:,k) = signalCube(:,:,k).*repmat(srFilt3(:,k),[1,N]); % .*repmat(srFilt3(:,k),[1,N]); 
end

%% combine signals; first, derive the relative weightings for the different frequencies: 
mixWeights0 = (1/K)*ones(T,N,K); % naive weighting rule 
mixWeights1 = mixWeights0; 
mixWeights = mixWeights0; 
tempSeeds = repmat(1/K,[1,N]); 
for k = 1:K 
    for t = 261:T 
       mixWeights1(t,:,k) = 1/K*((volFilt(t,:)<0)); 
    end % for t
    if mod(k,10)==0
       disp(['k = ',num2str(k)])
    end % if
end % for k
temp2 = mixWeights1;
for k = 1:K 
    temp2(:,:,k) = calcEWA(squeeze(mixWeights1(:,:,k)),5,tempSeeds); 
%    mixWeights(:,:,k) = 0.5*mixWeights0(:,:,k) + 0.5*temp2(:,:,k); 
    mixWeights(:,:,k) = 0.33*mixWeights0(:,:,k) + 0.67*temp2(:,:,k); 
end % for k 

% here combine signals across the k lookback frequencies:
signal0 = zeros(T,N); 
for n = 1:N
   signal0(:,n) = sum((signalCube(:,n,:).*mixWeights(:,n,:)),3); % sum along k-th dimension 
end 

t0 = find(round(data.dates,0)==startDate); 
if isempty(t0) && startDate < data.dates(1,1)
   t0 = 1;
   disp('WARNING: startDate is less than the first data in data.dates')
elseif isempty(t0)
   k = 0;
   startDate = startDate+1;  
   while isempty(t0) && k < 21
      t0 = find(round(data.dates,0)==startDate); 
      k = k+1; 
   end % while 
end 
tempDates = data.dates(t0:end); 
signal.assetIDs = data.header; 
signal.dates = tempDates;
signal.values = signal0(t0:end,:); 
end % fn

% volTemp = 0.5*(vol(6:end-5,:)+vol(1:end-10,:));
% volChg = [zeros(10,N); ma((vol(11:end,:) - volTemp),5)./volTemp]; 
% volFilt = (volChg>0.0 & volRank>0.075) - (volChg<0.0 & volRank<0.075);

% % informal test to see if a given lookback length,"k", is senstive to vol:
% tempTable(1,:) = 1:K;
% tempTable(2:5,:)=zeros(4,K);
% for k =1:K
%     temp=sum(squeeze(rawPnL(:,:,k)),2);
%     temp1=sum(squeeze(rawPnL(:,:,k)).*(volFilt>0),2);
%     temp2=sum(squeeze(rawPnL(:,:,k)).*(volFilt==0),2);
%     temp3=sum(squeeze(rawPnL(:,:,k)).*(volFilt<0),2);
%     tempTable(2:5,k) =[16*mean([temp, temp1, temp2, temp3])./std([temp, temp1, temp2, temp3])]';
% end % for
% tempTable %#ok
% 
% tempTable2(1,:) = 1:K;
% tempTable2(2:5,:)=zeros(4,K);
% for k =1:K
%     temp=sum(squeeze(rawPnL(2750:end,:,k)),2);
%     temp1=sum(squeeze(rawPnL(2750:end,:,k)).*(volFilt(2750:end,:)>0),2);
%     temp2=sum(squeeze(rawPnL(2750:end,:,k)).*(volFilt(2750:end,:)==0),2);
%     temp3=sum(squeeze(rawPnL(2750:end,:,k)).*(volFilt(2750:end,:)<0),2);
%     tempTable2(2:5,k) =[16*mean([temp, temp1, temp2, temp3])./std([temp, temp1, temp2, temp3])]';
% end % for
% tempTable2 %#ok

% temp = zeros(T,N,K); 
% tempS = temp; tempM = temp; tempL = temp;
% lkBkLong = 126; 
% lkBkMedm = 63; 
% lkBkShrt = 31; 
% for k = 1:K 
%     for t = 261:T 
%        temp(t,:,k) = 16*mean(rawPnL(1:t-1,:,k))./std(rtns(1:t-1,:))./mean(abs(signalCube(1:t-1,:,k))); 
%        tempS(t,:,k) = 16*mean(rawPnL(t-lkBkShrt:t-1,:,k))./std(rtns(t-lkBkShrt:t-1,:))./mean(abs(signalCube(t-lkBkShrt:t-1,:,k))); 
%        tempM(t,:,k) = 16*mean(rawPnL(t-lkBkMedm:t-1,:,k))./std(rtns(t-lkBkMedm:t-1,:))./mean(abs(signalCube(t-lkBkMedm:t-1,:,k))); 
%        tempL(t,:,k) = 16*mean(rawPnL(t-lkBkLong:t-1,:,k))./std(rtns(t-lkBkLong:t-1,:))./mean(abs(signalCube(t-lkBkLong:t-1,:,k))); 
%        tempSign = -0.5*((tempM(t,:,k) < 0) & (tempS(t,:,k) < 0)) - 0.5*((tempL(t,:,k)<0) & (tempM(t,:,k)<0) & (tempS(t,:,k) < 0)); 
% %       mixWeights1(t,:,k) = 1/K*((volFilt(t,:)<0) + 2*min([(temp(t,:,k) > 0.25).*temp(t,:,k); tempCeil])); 
%        mixWeights1(t,:,k) = 1/K*((volFilt(t,:)<0)); % + 2*min([(temp(t,:,k) > 0.25).*temp(t,:,k); tempCeil])); 
%        mixWeights1(t,:,k) = mixWeights1(t,:,k).*tempSign;
%     end % for t
%     if mod(k,25)==0
%        disp(['k = ',num2str(k)])
%     end % if
% end % for k