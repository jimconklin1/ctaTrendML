function [omega, vol, rho] = calcRollingRiskMatrix(assetData,lookback)
N = size(assetData.close,2);
T = size(assetData.close,1);
rho = zeros(N,N,T);
vol = zeros(T,N); 
omega = zeros(N,N,T);
for t = lookback+1:T
   cTemp = cov(assetData.close(t-lookback:t,:)); 
   omega(:,:,t) = cTemp;
   vol(t,:) = sqrt(diag(cTemp));
   rho(:,:,t) = cTemp./(vol(t,:)'*vol(t,:)); 
end 
end % fn