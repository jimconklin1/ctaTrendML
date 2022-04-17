function attributionTable = populateRiskParityHistAttr(ctx, simConfig, outputRP)

timeSlices = {'1997-01-01', '2004-12-31';...
              '2005-01-01', '2007-12-31';...
              '2008-01-01', '2009-06-30';...
              '2009-07-01', '2012-12-31';...
              '2013-01-01', '2014-12-31';...
              '2015-01-01', 'today'};

dailyReturns = zeros(length(outputRP.allPnl), 7);
dailyReturns(:, 1) = outputRP.allPnl;
for i = 1 : length(simConfig.assetClassHeader)
    index = ismember(simConfig.assetClass, simConfig.assetClassHeader{i});
    dailyReturns(:, i + 1) = nansum(outputRP.pnl(:, index), 2);
end
dailyReturns(:, 5) = nansum([outputRP.usPnl, outputRP.caPnl], 2);
dailyReturns(:, 6) = nansum([outputRP.xmPnl, outputRP.gbPnl], 2);
dailyReturns(:, 7) = nansum([outputRP.jpPnl, outputRP.auPnl, outputRP.krPnl], 2);

attributionTable = zeros(length(timeSlices)*3, 7);
for i = 1 : length(timeSlices)
    attributionTable(((i*3-2):(i*3)), :) = computeHistoricalAttribution(dailyReturns, outputRP.dates, timeSlices{i, 1}, timeSlices{i, 2});
end

csvwrite(ctx.conf.dataDest, attributionTable);

end