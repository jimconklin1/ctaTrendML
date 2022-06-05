function DataSourceComparison()

data = readtable('\\pnamfsdg02.investments.aig.net\Group03\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\DATA\Data.csv');

figure('Name', 'Data Source Comparison');
tiledlayout(4, 2, 'TileSpacing', 'Compact');

ax1 = nexttile;
plot(ax1, data.DATE, [data.IQ_DIV_SHARE, data.DVD_SH_12M]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('Dividend Per Share');

ax2 = nexttile;
plot(ax2, data.DATE, -1 * data.CF_DECR_CAP_STOCK);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Bloomberg', 'Location', 'northwest');
title('Buyback');

ax3 = nexttile;
plot(ax3, data.DATE, [data.IQ_BASIC_EPS_EXCL, data.IS_EPS]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('Earnings Per Share');

ax4 = nexttile;
plot(ax4, data.DATE, [data.IQ_EBITDA, data.EBITDA]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('EBITDA');

ax5 = nexttile;
plot(ax5, data.DATE, [data.IQ_EBIT, data.EBIT]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('EBIT');

ax6 = nexttile;
plot(ax6, data.DATE, [data.IQ_CASH_OPER, data.CASH_FLOW_PER_SH]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('Operating Cash flow');

ax7 = nexttile;
plot(ax7, data.DATE, [data.IQ_CF_SHARE, data.FREE_CASH_FLOW_PER_SH]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('Free Cash Flow Per Share');

ax8 = nexttile;
plot(ax8, data.DATE, [data.IQ_TOTAL_REVENUE, data.REVENUE_PER_SH]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Capital IQ', 'Bloomberg', 'Location', 'northwest');
title('Total Revenue');

y = data.IQ_DIV_SHARE - data.CF_DECR_CAP_STOCK;
x = data.IQ_EBITDA;
mdl1 = fitlm(x(1:end-1), y(2:end))
figure('Name', 'Initial Regression');
tiledlayout(2, 2, 'TileSpacing', 'Compact');
ax1 = nexttile;
yyaxis left;
plot(ax1, data.DATE, y);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(ax1, data.DATE, x);
hold on
plot(ax1, data.DATE(2:end), x(1:end-1));
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Dividend + Buyback', 'EBITDA', 'Previous Quarter EBITDA', 'Location', 'northwest');
ax2 = nexttile;
plot(ax2, mdl1)
ax3 = nexttile;
scatter(ax3, mdl1.Fitted, mdl1.Residuals.Raw);

end

