function performanceStats = computePerfStats(dailyReturns,dates,dailyPercentTCs,portfolioWts)

if (~isdeployed)
    addpath 'H:\GIT\matlabUtils\JG\MyFunctions';
end

positiveReturns = dailyReturns(dailyReturns >= 0);
negativeReturns = dailyReturns(dailyReturns < 0);

if nargin > 1 && ~isempty(dates)
    performanceStats.startDate = year(dates(1))*10000+month(dates(1))*100+day(dates(1));
    performanceStats.endDate = year(dates(end))*10000+month(dates(end))*100+day(dates(end));
end 
performanceStats.numberOfObservations = size(dailyReturns, 1);
numberOfPositiveDays = size(positiveReturns, 1);
performanceStats.numberOfPositiveDaysOverAllDays = 100 * numberOfPositiveDays / (performanceStats.numberOfObservations);

performanceStats.maxDailyReturn = 100 * max(dailyReturns);
performanceStats.minDailyReturn = 100 * min(dailyReturns);
performanceStats.averageDailyReturn = 100 * mean(dailyReturns);
performanceStats.medianDailyReturn = 100 * median(dailyReturns);
performanceStats.averagePositiveDailyReturn = 100 * mean(positiveReturns);
performanceStats.averageNegativeDailyReturn = 100 * mean(negativeReturns);
performanceStats.annualizedVolatility = 16 * std(dailyReturns);
performanceStats.informationRatio = 16 * mean(dailyReturns) / std(dailyReturns);
performanceStats.sortinoRatio = 16 * mean(dailyReturns) / std(negativeReturns);
[~, maxDrawdown, ~] = drawdown(dailyReturns, 'return');
performanceStats.maxDrawdownPercent = 100 * maxDrawdown;

performanceStats.numberOfBusDays = computeBusDate(dailyReturns);
performanceStats.numberOfBusDaysOverPositiveDays = 100 * (performanceStats.numberOfBusDays) / numberOfPositiveDays;
performanceStats.numberOfBusDaysOverAllDays = 100 * (performanceStats.numberOfBusDays) / (performanceStats.numberOfObservations);

if nargin > 2 && ~isempty(dailyPercentTCs)
    performanceStats.transCostAsPercOfRtns = 100 * nansum(dailyPercentTCs)/nansum(dailyReturns); 
end % if

if nargin > 3 && ~isempty(portfolioWts)
    performanceStats.annualTurnover = 260 * nanmean(nansum(abs(portfolioWts(2:end,:)-portfolioWts(1:end-1,:)),2)); 
end % if

end % fn