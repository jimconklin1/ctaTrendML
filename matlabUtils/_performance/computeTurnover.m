function output = computeTurnover(inputTrades, inputWeights, inputDates, startDate, endDate)

if (strcmp(endDate, 'today'))
    endDate = datestr(today, 'yyyy-mm-dd');
end

startIndex = find(inputDates == min(inputDates(inputDates - datenum(startDate) > 0)));
endIndex = find(inputDates == max(inputDates(inputDates - datenum(endDate) < 0)));
numberOfYears = yearfrac(inputDates(startIndex), inputDates(endIndex));
dailyTrades = inputTrades(startIndex : endIndex, :);
[~, length] = size(dailyTrades);

output = zeros(1, length);
averagePosition = nansum(inputWeights(:, 1)) / (endIndex - startIndex + 1);
for i = 1 : length
    output(:, i) = nansum(abs(dailyTrades(:, i))) / numberOfYears / averagePosition;
end

end

