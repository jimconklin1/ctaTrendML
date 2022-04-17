function perfStats = populatePerfStatsTable(dailyNetReturns, assetDailyReturns, assetHeader, dateNums, oosDate)

oosDateNum = datenum(oosDate);
outOfSampleIndex = find(dateNums == min(dateNums(dateNums - oosDateNum > 0)));

% In Sample Performance Stats Table Data
inSampleDailyReturns = dailyNetReturns(1 : outOfSampleIndex - 1);
perfStats.inSamplePerfStats = computePerfStats(inSampleDailyReturns);
inSampleAssetDailyReturns = assetDailyReturns(1 : outOfSampleIndex - 1, :);
perfStats.inSampleAssetReturns = computeAssetReturns(inSampleAssetDailyReturns, assetHeader);
perfStats.inSampleTcOverNetReturns = nansum(nansum(inSampleAssetDailyReturns, 2)) / nansum(inSampleDailyReturns) - 1;

% Out of Sample Performance Stats Table Data
outOfSampleDailyReturns = dailyNetReturns(outOfSampleIndex : end);
perfStats.outofSamplePerfStats = computePerfStats(outOfSampleDailyReturns);
outOfSampleAssetDailyReturns = assetDailyReturns(outOfSampleIndex : end, :);
perfStats.outOfSampleAssetReturns = computeAssetReturns(outOfSampleAssetDailyReturns, assetHeader);
perfStats.outOfSampleTcOverNetReturns = nansum(nansum(outOfSampleAssetDailyReturns, 2)) / nansum(outOfSampleDailyReturns) - 1;

% Total Performance Stats Table Data
perfStats.totalPerfStats = computePerfStats(dailyNetReturns);
perfStats.totalAssetReturns = computeAssetReturns(assetDailyReturns, assetHeader);
perfStats.totalTcOverNetReturn = nansum(nansum(assetDailyReturns, 2)) / nansum(dailyNetReturns) - 1;

end