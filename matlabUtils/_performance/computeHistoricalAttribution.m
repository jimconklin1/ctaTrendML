function output = computeHistoricalAttribution(inputReturns, inputDates, startDate, endDate)

if (strcmp(endDate, 'today'))
    endDate = datestr(today, 'yyyy-mm-dd');
end

startIndex = find(inputDates == min(inputDates(inputDates - datenum(startDate) > 0)));
endIndex = find(inputDates == max(inputDates(inputDates - datenum(endDate) < 0)));
numberOfYears = yearfrac(inputDates(startIndex), inputDates(endIndex));
dailyReturns = inputReturns(startIndex : endIndex, :);
[~, length] = size(dailyReturns);
output = zeros(3, length);

for i = 1 : length
    averageAnnReturn = nansum(dailyReturns(:, i)) / numberOfYears;
    sharpeRatio = sqrt(252) * mean(dailyReturns(:, i)) / std(dailyReturns(:, i));
    [~, worstDrawdown, ~] = drawdown(dailyReturns(:, i), 'return');   
    output(:, i) = [averageAnnReturn; sharpeRatio; worstDrawdown];
end

end