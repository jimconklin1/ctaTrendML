function [assetMu2,assetCov2,assetCos2,assetCok2,varianceTarget] = AdjustAssetView(holdingPeriods,assetMu,assetCov,assetCos,assetCok,...
                                                                                   erView,volView,varianceTarget)
% "view" inputs, varianceTarget have annual units
% output moments will have time units of input returns

% convert views from annual units to units of periodicity input returns
if nargin < 8
    varianceTarget = []; 
else 
    varianceTarget = varianceTarget*holdingPeriods/12;
end 
assetMu2 = erView*(holdingPeriods/12); 
volView = volView*sqrt(holdingPeriods/12);

% re-calibrate var-cov matrix to incorporate volViews:
assetVols = diag(assetCov).^0.5;
volRatios = volView./assetVols;
assetCov2 = diag(volRatios)*assetCov*diag(volRatios);

% re-calibrate co-skew matrix to incorporate volViews:
nData = size(assetMu,1);
assetCos2 = assetCos;
for i=1:nData
    for j=1:nData
        for k=1:nData
            assetCos2(j,nData*(i-1)+k) = assetCos2(j,nData*(i-1)+k)*volRatios(i,1)*volRatios(j,1)*volRatios(k,1);
        end
    end
end

% re-calibrate co-kurtosis matrix to incorporate volViews:
assetCok2 = assetCok;
for i=1:nData
    for j=1:nData
        for k=1:nData
            for l=1:nData
                assetCok2(k,(nData*(i-1)+j-1)*nData+l) = assetCok2(k,(nData*(i-1)+j-1)*nData+l)*volRatios(i,1)*volRatios(j,1)*volRatios(k,1)*volRatios(l,1);
            end
        end
    end
end

end 