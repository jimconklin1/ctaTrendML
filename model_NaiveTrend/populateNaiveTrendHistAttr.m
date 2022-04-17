function populateNaiveTrendHistAttr(portSimCombined, config, dataConfig)

timeSlices = {'2000-01-01', '2004-12-31';...
              '2005-01-01', '2007-12-31';...
              '2008-01-01', '2009-06-30';...
              '2009-07-01', '2012-12-31';...
              '2013-01-01', '2014-12-31';...
              '2015-01-01', 'today'};

indexAmerica = ismember(portSimCombined.header, dataConfig.americaHeaders);
indexEmea = ismember(portSimCombined.header, dataConfig.emeaHeader);
indexAsiaPacific = ismember(portSimCombined.header, dataConfig.asiaPacificHeaders);
indexEq = ismember(portSimCombined.header, dataConfig.equity.header);
indexRates = ismember(portSimCombined.header, dataConfig.rates.header);
indexCmd = ismember(portSimCombined.header, dataConfig.comdty.header);
indexCcy = ismember(portSimCombined.header, dataConfig.ccy.header);
          
dailyReturns = [portSimCombined.totPnl,...
    portSimCombined.equPnl, portSimCombined.ratesPnl, portSimCombined.cmdPnl, portSimCombined.ccyPnl,...
    nansum(portSimCombined.pnl(:, indexAmerica), 2) + portSimCombined.cmdPnl / 3.0,...
    nansum(portSimCombined.pnl(:, indexEmea), 2) + portSimCombined.cmdPnl / 3.0,...
    nansum(portSimCombined.pnl(:, indexAsiaPacific), 2) + portSimCombined.cmdPnl / 3.0];

dailyTrades = [nansum(abs(portSimCombined.trades), 2),... 
    nansum(abs(portSimCombined.trades(:, indexEq)), 2), nansum(abs(portSimCombined.trades(:, indexRates)), 2),...
    nansum(abs(portSimCombined.trades(:, indexCmd)), 2), nansum(abs(portSimCombined.trades(:, indexCcy)), 2),...
    nansum(abs(portSimCombined.trades(:, indexAmerica)), 2) + nansum(abs(portSimCombined.trades(:, indexCmd)), 2) / 3.0,...
    nansum(abs(portSimCombined.trades(:, indexEmea)), 2) + nansum(abs(portSimCombined.trades(:, indexCmd)), 2) / 3.0,...
    nansum(abs(portSimCombined.trades(:, indexAsiaPacific)), 2) + nansum(abs(portSimCombined.trades(:, indexCmd)), 2) / 3.0];

dailyWeights = [nansum(portSimCombined.wts, 2),...
    portSimCombined.equWts, portSimCombined.ratesWts, portSimCombined.cmdWts, portSimCombined.ccyWts,...
    nansum(portSimCombined.wts(:, indexAmerica), 2) + portSimCombined.cmdWts / 3.0,...
    nansum(portSimCombined.wts(:, indexEmea), 2) + portSimCombined.cmdWts / 3.0,...
    nansum(portSimCombined.wts(:, indexAsiaPacific), 2) + portSimCombined.cmdWts / 3.0];

attributionTable = zeros(length(timeSlices)*4, 8);
for i = 1 : length(timeSlices)
    attributionTable(((i*4-3):(i*4-1)), :) = computeHistoricalAttribution(dailyReturns, portSimCombined.dates, timeSlices{i, 1}, timeSlices{i, 2});
    attributionTable(i*4, :) = computeTurnover(dailyTrades, dailyWeights, portSimCombined.dates, timeSlices{i, 1}, timeSlices{i, 2});    
end

csvwrite(strcat(config.dataPath, 'NaiveTrendHistoricalAttributions.csv'), attributionTable);

end