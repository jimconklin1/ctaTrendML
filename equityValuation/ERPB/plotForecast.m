function plotForecast(data, forecast)

for i = 1 : length(forecast.CalcDate)
    forecast.CalcDate(i) = lbusdate(year(forecast.CalcDate(i)), month(forecast.CalcDate(i)) + 1);
end

figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
subplot(2, 4, 1);
plot(data.DataDate, data.Actual, 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ1, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ1 Forecast');

subplot(2, 4, 2);
plot(data.DataDate(1:end-1), data.Actual(2:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ2, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ2 Forecast');

subplot(2, 4, 3);
plot(data.DataDate(1:end-2), data.Actual(3:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ3, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ3 Forecast');

subplot(2, 4, 4);
plot(data.DataDate(1:end-3), data.Actual(4:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ4, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ4 Forecast');

subplot(2, 4, 5);
plot(data.DataDate(1:end-4), data.Actual(5:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ5, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ5 Forecast');

subplot(2, 4, 6);
plot(data.DataDate(1:end-5), data.Actual(6:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ6, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ6 Forecast');

subplot(2, 4, 7);
plot(data.DataDate(1:end-6), data.Actual(7:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ7, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ7 Forecast');

subplot(2, 4, 8);
plot(data.DataDate(1:end-7), data.Actual(8:end), 'LineWidth', 2);
hold on;
plot(forecast.CalcDate, forecast.FQ8, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([forecast.CalcDate(1), forecast.CalcDate(end)]);
grid on;
grid minor;
legend('BBG Actual', 'Forecast', 'Location', 'northwest');
title('FQ8 Forecast');

end