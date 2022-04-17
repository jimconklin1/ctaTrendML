function assetReturns = computeAssetReturns(assetDailyReturns, assetHeader)

returns = zeros(1, length(assetHeader));
for i = 1 : length(assetHeader)
    returns(i) = nansum(assetDailyReturns(:, i));
end

assetReturns.assetHeader = assetHeader;
assetReturns.returns = returns;

end

