function corr = calcDynCorrCSRP(assetData,simConfig)
% keeps covs in daily units
buffer = 260; 
a = simConfig.corrShrinkFactor; 
hlCorr(1) = simConfig.corrHL1; 
hlCorr(2) = simConfig.corrHL2; 
alphaCorr = simConfig.corrAlpha;
rtns = assetData.close; 
[T,N] = size(rtns);
tempMat = (1-a)*eye(N) + a*ones(N,N);
cov1 = escov(rtns, hlCorr(1), 'D', [], [], buffer, [], 'D'); 
cov2 = escov(rtns, hlCorr(2), 'D', [], [], buffer, [], 'D'); 
cov = alphaCorr*cov1+(1-alphaCorr)*cov2; 
clear cov1 cov2; 
corr = zeros(size(cov)); 
for t = 1:T 
   volVec = sqrt(diag(cov(:,:,t))); 
   xx = squeeze(cov(:,:,t)./(volVec*volVec')).*tempMat; 
   i = find(isnan(diag(xx)));
   for ii = 1:length(i); xx(i(ii),i(ii)) = 1; end % replace diagonal NaNs w/ 1s
   xx(isnan(xx)) = 0; % replace off-diagonal NaNs w/ 0s
   corr(:,:,t) = xx;
end % for t
end % fn