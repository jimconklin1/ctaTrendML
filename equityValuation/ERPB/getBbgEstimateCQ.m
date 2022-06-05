function results = getBbgEstimateCQ()

c = blp;
startDate = '01/01/2020';
indexId = 'SPX Index';
field = 'BEST_EPS';

data1 = history(c, indexId, field, startDate, datestr(today, 'mm/dd/yyyy'), 'daily', 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '1FQ'});
data2 = history(c, indexId, field, startDate, datestr(today, 'mm/dd/yyyy'), 'daily', 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '2FQ'});
data3 = history(c, indexId, field, startDate, datestr(today, 'mm/dd/yyyy'), 'daily', 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '3FQ'});
data4 = history(c, indexId, field, startDate, datestr(today, 'mm/dd/yyyy'), 'daily', 'USD', 'overridefields', {'BEST_FPERIOD_OVERRIDE', '4FQ'});
data = [data1, data2(:, 2), data3(:, 2), data4(:, 2)];

results = zeros(size(data, 1), 5);
results(:, 1) = data(:, 1);
results(quarter(results(:, 1)) == 1, 2) = data(quarter(data(:, 1)) == 1, 2);
results(quarter(results(:, 1)) == 2, 3) = data(quarter(data(:, 1)) == 2, 2);
results(quarter(results(:, 1)) == 3, 4) = data(quarter(data(:, 1)) == 3, 2);

results(quarter(results(:, 1)) == 1, 3) = data(quarter(data(:, 1)) == 1, 3);
results(quarter(results(:, 1)) == 2, 4) = data(quarter(data(:, 1)) == 2, 3);
results(quarter(results(:, 1)) == 3, 5) = data(quarter(data(:, 1)) == 3, 3);

results(quarter(results(:, 1)) == 1, 4) = data(quarter(data(:, 1)) == 1, 4);
results(quarter(results(:, 1)) == 2, 5) = data(quarter(data(:, 1)) == 2, 4);

results(quarter(results(:, 1)) == 1, 5) = data(quarter(data(:, 1)) == 1, 5);

results(results == 0) = nan;
figure;
plot(results(:, 1), results(:, 2 : 5), 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([results(1, 1), results(end, 1)]);

set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend('CQ1', 'CQ2', 'CQ3', 'CQ4', 'Location', 'southwest');
title(strcat(indexId, ' EPS Estimates'));

results = array2table(results, 'VariableNames', {'EstimationDate', 'CQ1', 'CQ2', 'CQ3', 'CQ4'});

end