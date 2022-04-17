function [backtest, returnsTable] = QuantBackTest(modelId)
    addpath H:\GIT\matlabUtils\_data;
    addpath H:\GIT\matlabUtils\_performance;
    addpath H:\GIT\mtsrp;

    load(strcat('S:\quantQA\DATA\signal\Simplex\Local Settings (After Fix)\', modelId, '_2sl_pnl_series.mat'));
    eval(strcat('dailyReturns = cell2mat(', modelId, '_2sl_pnl_series(:, 2));'));
    eval(strcat('dates = datenum(cell2mat(', modelId, '_2sl_pnl_series(:, 1)));'));

    plot(dates, cumsum(dailyReturns));
    datetick('x', 'dd/mm/yyyy');
    title(strcat({'Cumulative PnL - '}, {upper(modelId(1))}, {modelId(2:end)}, {' Model - 2Std SL'}));
    grid;
    xlabel('Time');
    ylabel(strcat({'PnL - '}, {upper(modelId(1))}, {modelId(2:end)}, {' Model - 2Std SL'}));

    backtest.totalPnl = sum(dailyReturns);
    backtest.averagePnl = mean(dailyReturns);
    backtest.stDev = std(dailyReturns);
    [~, backtest.maxDrawdown, ~] = drawdown(dailyReturns, 'return');
    backtest.p2d = backtest.totalPnl / backtest.maxDrawdown;
    backtest.maxPnl = max(dailyReturns);
    backtest.minPnl = min(dailyReturns);
    backtest.sharpe = sqrt(252) * backtest.averagePnl / backtest.stDev;
    spx = tsrp.fetch_bbg_daily_close({'spx_index'}, '2005-01-01', '2017-01-20');
    spxReturn = [0; spx(2 : end, 2) ./ spx(1 : end-1, 2) - 1];
    spxReturn(isnan(spxReturn)) = 0;
    alignedSpx = alignNewDatesJC(spx(:, 1), spxReturn, dates, 0);
    backtest.corr2Market = corr(dailyReturns, alignedSpx);
    covMatrix = cov([dailyReturns, alignedSpx]);
    varVector = var([dailyReturns, alignedSpx]);
    backtest.beta = covMatrix(1, 2) / varVector(2);
    backtest.annReturn = 252 * backtest.averagePnl;
    backtest.annVol = sqrt(252) * backtest.stDev;
    backtest.sortinoRatio = sqrt(252) * backtest.averagePnl / std(dailyReturns(dailyReturns < 0));
    backtest.winningPerc = length(dailyReturns(dailyReturns >= 0)) / length(dailyReturns);
    backtest.avgDailyGain = mean(dailyReturns(dailyReturns >= 0));
    backtest.avgDailyLoss = mean(dailyReturns(dailyReturns < 0));
    backtest.dailyGainVol = std(dailyReturns(dailyReturns >= 0));
    backtest.dailyLossVol = std(dailyReturns(dailyReturns < 0));
    backtest.skewness = skewness(dailyReturns);
    backtest.kurtosis = kurtosis(dailyReturns);
    ma5 = ma(dailyReturns, 5);
    ma10 = ma(dailyReturns, 10);
    ma20 = ma(dailyReturns, 20);
    backtest.best5 = max(ma5) * 5;
    backtest.best10 = max(ma10) * 10;
    backtest.best20 = max(ma20) * 20;
    backtest.worst5 = min(ma5) * 5;
    backtest.worst10 = min(ma10) * 10;
    backtest.worst20 = min(ma20) * 20;
    backtest.winRate5 = length(ma5(ma5 >= 0)) / length(ma5);
    backtest.winRate10 = length(ma10(ma10 >= 0)) / length(ma10);
    backtest.winRate20 = length(ma20(ma20 >= 0)) / length(ma20);
    backtest.busNumber = computeBusDate(dailyReturns) / length(dailyReturns);
    
    startYear = year(dates(1));
    endYear = 2017;
    returnsTable = zeros(endYear - startYear + 1, 13);
    for i = 1 : length(dates)
        returnsTable(year(dates(i)) - startYear + 1, month(dates(i))) = returnsTable(year(dates(i)) - startYear + 1, month(dates(i))) + dailyReturns(i);
    end
    
    returnsTable(:, 13) = sum(returnsTable(:, 1:12), 2);
    
end
