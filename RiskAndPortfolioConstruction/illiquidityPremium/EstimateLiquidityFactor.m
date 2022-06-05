function liquidityFactor = EstimateLiquidityFactor(privateAssetReturns,factorReturns, useConstrainedPCA)

nAssets = size(privateAssetReturns,2);
resiAssetReturns = privateAssetReturns;
privateAssetAlphas = zeros(nAssets,1);

X = factorReturns;
for i=1:nAssets
    stats = regstats(privateAssetReturns(:,i),X,'linear',{'beta','yhat','tstat'});
    privateAssetAlphas(i,1) = stats.beta(1);
    resiAssetReturns(:,i) = resiAssetReturns(:,i) -stats.yhat;
end

if useConstrainedPCA
    C = cov(resiAssetReturns);
    objfun=@(x)-x'*C*x;
    w=ones(nAssets,1);
    w=fmincon(objfun,w,-C,zeros(nAssets,1),[],[],[],[],@normcon);
    liquidityFactor = resiAssetReturns*w;
    liquidityExposure = C*w/(w'*C*w);
else
    %Apply PCA to residuals
    [V,D] = eig(cov(resiAssetReturns));
    
    %Sort eigenvectors
    [D,permutation]=sort(diag(D),'descend');
    V=V(:,permutation);
    
    %Ensure all private assets have positive exposure to the liquidity factor
    if sum(V(:,1)>=0) < nAssets/2
        V(:,1)=V(:,1)*-1;
    end
    
    PCS = resiAssetReturns*V;
    liquidityFactor = PCS(:,1);
    liquidityExposure = V(1,:)';
end

%Estimate the liquidity risk premium
liquidRP = 1.0;
for i=1:nAssets
    if liquidityExposure(i,1)>0.0
        liquidRP = min(liquidRP,privateAssetAlphas(i,1)/liquidityExposure(i,1));
    end
end
liquidityFactor = liquidityFactor+liquidRP;


function [c, ceq] = normcon(w)
c=w'*w-1;
ceq=[];