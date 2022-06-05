function estimates = getBbgEstimate(startDate, endDate, ticker, field, frequency)

c = blp;

data1 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '1FQ'});
data2 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '2FQ'});
data3 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '3FQ'});
data4 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '4FQ'});
data5 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '5FQ'});
data6 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '6FQ'});
data7 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '7FQ'});
data8 = history(c, ticker, field, startDate, endDate, {frequency, 'calendar'}, 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '8FQ'});

estimates = nan(size(data1, 1), 9);
estimates(:, [1, 2]) = data1;
estimates(ismember(data1(:, 1), data2(:, 1)), 3) = data2(ismember(data2(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data3(:, 1)), 4) = data3(ismember(data3(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data4(:, 1)), 5) = data4(ismember(data4(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data5(:, 1)), 6) = data5(ismember(data5(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data6(:, 1)), 7) = data6(ismember(data6(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data7(:, 1)), 8) = data7(ismember(data7(:, 1), data1(:, 1)), 2);
estimates(ismember(data1(:, 1), data8(:, 1)), 9) = data8(ismember(data8(:, 1), data1(:, 1)), 2);

estimates = array2table(estimates, 'VariableNames', {'CalcDate', 'FQ1', 'FQ2', 'FQ3', 'FQ4', 'FQ5', 'FQ6', 'FQ7', 'FQ8'});

end