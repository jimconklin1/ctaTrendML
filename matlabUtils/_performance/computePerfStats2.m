function [performanceStats,performanceTable] = computePerfStats2(dailyReturns,dates,dailyPercentTCs,portfolioWts)

if (~isdeployed)
    addpath 'H:\GIT\matlabUtils\JG\MyFunctions';
end

positiveReturns = dailyReturns(dailyReturns > 0);
zeroReturns = dailyReturns(dailyReturns == 0);
negativeReturns = dailyReturns(dailyReturns < 0);

if nargin > 1 && ~isempty(dates)
    performanceStats.startDate = year(dates(1))*10000+month(dates(1))*100+day(dates(1));
    performanceStats.endDate = year(dates(end))*10000+month(dates(end))*100+day(dates(end));
end 
performanceStats.numberOfObservations = size(dailyReturns, 1);
numberOfPositiveDays = size(positiveReturns, 1);
numberOfZeroDays = size(zeroReturns, 1);
numberOfNegativeDays = size(negativeReturns, 1);
performanceStats.percentPositiveDays = 100 * numberOfPositiveDays / (performanceStats.numberOfObservations);
performanceStats.percentDaysZero = 100 * numberOfZeroDays / (performanceStats.numberOfObservations);
performanceStats.percentNegativeDays = 100 * numberOfNegativeDays / (performanceStats.numberOfObservations);

performanceStats.maxDailyReturn = 100 * max(dailyReturns);
performanceStats.minDailyReturn = 100 * min(dailyReturns);
performanceStats.averageDailyReturn = 100 * mean([positiveReturns; negativeReturns]);
performanceStats.medianDailyReturn = 100 * median([positiveReturns; negativeReturns]);
performanceStats.averagePositiveDailyReturn = 100 * mean(positiveReturns);
performanceStats.averageNegativeDailyReturn = 100 * mean(negativeReturns);
performanceStats.annualizedVolatility = 100*16 * std([positiveReturns; negativeReturns]);
performanceStats.informationRatio = 16 * mean([positiveReturns; negativeReturns]) / std([positiveReturns; negativeReturns]);
performanceStats.sortinoRatio = 16 * mean([positiveReturns; negativeReturns]) / std(negativeReturns);
[~, maxDrawdown, ~] = drawdown(dailyReturns, 'return');
performanceStats.maxDrawdownPercent = 100 * maxDrawdown;

performanceStats.numBusDays = computeBusDays(dailyReturns);
performanceStats.numBusDaysAsPercentOfPositiveDays = 100 * (performanceStats.numBusDays) / numberOfPositiveDays;
performanceStats.numBusDaysAsPercentOfActiveDays = 100 * (performanceStats.numBusDays) / (numberOfPositiveDays+numberOfNegativeDays);

if nargin > 2 && ~isempty(dailyPercentTCs)
    performanceStats.transCostAsPercOfRtns = 100 * sum(nansum(dailyPercentTCs,2))/sum(nansum(dailyReturns,2)); 
end % if

if nargin > 3 && ~isempty(portfolioWts)
    performanceStats.annualTurnover = 260 * nanmean(nansum(abs(portfolioWts(2:end,:)-portfolioWts(1:end-1,:)),2)); 
end % if

performanceTable = struct2table(performanceStats);
end % fn