function corr = calcDynCorrCSRP2(assetData,riskConfig)
% keeps covs in daily units
buffer = riskConfig.buffer; 
a = riskConfig.corrShrinkFactor; 
hlCorr = riskConfig.corrHL; 
rtns = assetData.close; 
[T,N] = size(rtns);
tempMat = (1-a)*eye(N) + a*ones(N,N);
cov = escov(rtns, hlCorr, 'D', [], [], buffer, [], 'D'); 
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