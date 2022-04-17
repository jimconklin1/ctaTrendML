function signal = MMAsignalsEnhanced(prices,rtns,MAs,MAwts)
% This function calculates the moving average signal across different
% zones weighted by the weights assigned to each zone.

% checking to see if all the arguments are there
if (nargin < 4)
    error('Bad number of arguments');
end 

% checking to make sure sum of weights is 1
if round(sum(MAwts)) ~= 1
    error('Sum of zone weights should add up to 1');
end 
    
[T,N] = size(prices); 
K = length(MAwts); 
dlyVolFloor = 0.0025;
rawPnL = zeros(T,N,K); 
signalCube = zeros(T,N,K); 
signal = zeros(T,N);

% find universe of lookbacks
z = MAs;
lbMap = MAs;
lookbacks = zeros(max(max(z)),1);
lookbacks(1) = 1;
for j=1:size(z, 1)
    lookbacks(z(j, 1)) = 1;
    lookbacks(z(j, 2)) = 1;
end
lookbacks = find(lookbacks);
clear z;

% compute weighted combination of MA cross-over signals:
for n = 1:N
    % compute moving average for our universe of looksbacks
    MAs = nan(length(prices(:,n)), length(lookbacks));
    for i=1:length(lookbacks)
        MAs(:, i) = calcMA(prices(:,n), lookbacks(i));
    end % for i
    
    % make sure that weights across all MAs add up to 1
    MAwts = MAwts/sum(MAwts);
    
    % compute signals based on moving average combinations
    for i = 1:length(lbMap)
        lb1 = lookbacks==lbMap(i,1);
        lb2 = lookbacks==lbMap(i,2);
        signalCube(:,n,i) = (sign(MAs(:, lb1) - MAs(:, lb2))); 
        signal(:,n) = signal(:,n) +  MAwts(i)*(sign(MAs(:, lb1) - MAs(:, lb2)));
    end % for i 
end % for n 
  
% informal test to see if a given lookback length,"k", is senstive to vol:
mmaParams = evalin('caller','mmaParams');

% compute different volatility measures for use in filters: 
vol1 = calcEWAvol(rtns.values,mmaParams.volHL(1),0,nanstd(rtns.values(1:130,:)),true,3.5); 
vol2 = calcEWAvol(rtns.values,mmaParams.volHL(2),0,nanstd(rtns.values(1:130,:)),true,3.5); 
vol3 = calcEWAvol(rtns.values,mmaParams.volHL(3),0,nanstd(rtns.values(1:260,:)),true,3.5); 
vol = 0.5*vol1 + 0.5*vol2; 
volSlow = 0.2*vol1 + 0.8*vol3; 
volRank = (vol - volSlow)./volSlow; 
volFilt = zeros(T,N); 
volFilt = volFilt + (volRank>mmaParams.volThresh(2)) - (volRank<mmaParams.volThresh(1)); 
vol(isnan(vol)) = dlyVolFloor;

for k = 1:K
   for n = 1:N
       rawPnL(:,n,k) = dlyVolFloor*[0; rtns.values(2:end,n).*signalCube(1:end-1,n,k)./vol(1:end-1,n)]; 
   end % for n 
end % for k 

% for k = 1:K
%    for n = 1:N
%        rawPnL(:,n,k) = [0; rtns.values(2:end,n).*signalCube(1:end-1,n,k)]; 
%    end % for n 
% end % for k 

%% combine signals; first, derive the relative weightings for the different frequencies: 
mixWeights0 = (1/K)*ones(T,N,K); % naive weighting rule 
mixWeights1 = mixWeights0; 
mixWeights = mixWeights0; 
temp = zeros(T,N,K); 
tempSeeds = repmat(1/K,[1,N]); 
% tempCeil = repmat(0.5,[1,N]); 
for k = 1:K
    for t = 261:T
       temp(t,:,k) = 16*mean(rawPnL(1:t-1,:,k))./std(rtns.values(1:t-1,:))./mean(abs(signalCube(1:t-1,:,k))); 
%       mixWeights1(t,:,k) = 1/K*((volFilt(t,:)<0) + 2*min([(temp(t,:,k) > 0.25).*temp(t,:,k); tempCeil])); 
       mixWeights1(t,:,k) = 1/K*((volFilt(t,:)<0)); % + 2*min([(temp(t,:,k) > 0.25).*temp(t,:,k); tempCeil])); 
    end % for t
    if mod(k,10)==0
       disp(['k = ',num2str(k)])
    end % if
end % for k
temp2 = mixWeights1;
for k = 1:K 
    temp2(:,:,k) = calcEWA(squeeze(mixWeights1(:,:,k)),5,tempSeeds); 
    mixWeights(:,:,k) = 0.33*mixWeights0(:,:,k) + 0.67*temp2(:,:,k); 
end % for k 

signal = zeros(T,N); 
for n = 1:N
   signal(:,n) = sum((signalCube(:,n,:).*mixWeights(:,n,:)),3); % sum along k-th dimension 
end 

end % fn
 
% SRsig1 = zeros(T,K);
% SRsig2 = zeros(T,K);
% SRsig3 = zeros(T,K);
% srFilt1 = zeros(T,K); 
% srFilt2 = zeros(T,K); 
% srFilt3 = zeros(T,K); 
% srLookback = ones(3,K); 
% rtns_k.header = {num2str(k)}; 
% rtns_k.dates = rtns.dates;
% MAwin = lbMap(:,1)+lbMap(:,2); 
% for k = 1:K 
%    srLookback(1,k) = MAwin(1); % round((MAwin(1)+MAwin(k))/2); 
%    srLookback(2,k) = round((MAwin(1)+MAwin(K))/2);  
%    srLookback(3,k) = MAwin(K); %round((MAwin(K)+MAwin(k))/1.75); 
%    rtns_k.values = sum(squeeze(rawPnL(:,:,k)),2); 
%    [temp,~] = calcMMSRsig(rtns_k,srLookback(1,k)); SRsig1(:,k) = temp.values;
%    [temp,~] = calcMMSRsig(rtns_k,srLookback(2,k)); SRsig2(:,k) = temp.values;
%    [temp,~] = calcMMSRsig(rtns_k,srLookback(3,k)); SRsig3(:,k) = temp.values;
%    srFilt1(:,k) = ~(SRsig1(:,k)<0); 
%    srFilt2(:,k) = ~(SRsig2(:,k)<0); % - (SRsig1(:,k)<0);
%    srFilt3(:,k) = ~(SRsig3(:,k)<0); % ~(SRsig1(:,k)<0 | SRsig2(:,k)<0);
% end 
% %srFilt2(srFilt2==0) = -1; 
% %srFilt3(srFilt3==0) = -1; 
% %k=k+1; plot([calcCum((sum(squeeze(rawPnL(:,:,k)),2)),1),SRsig1(:,k),SRsig2(:,k),(srFilt1(:,k)-2)])
% 
% for k = 1:K 
%    signalCube(:,:,k) = signalCube(:,:,k).*repmat(srFilt3(:,k),[1,N]); 
% end 