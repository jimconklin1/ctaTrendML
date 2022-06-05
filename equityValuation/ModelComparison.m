function ModelComparison()

data = readtable('\\pnamfsdg02.investments.aig.net\Group03\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\DATA\Data.csv');
data.PAYOUT = data.DVD_SH_12M - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
data.IQ_PAYOUT = data.IQ_DIV_SHARE - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
data.IQ_ROC = data.IQ_RETURN_CAPITAL;
data.IQ_ROC(end-8:end) = data.IQ_ROC(end-8:end) / (1 - 0.35 - 0.025) * (1 - 0.21 - 0.025);

c = blp;
bondData = history(c, {'GTUSD30Y Govt', 'CDX IG CDSI GEN 5Y Corp', 'CONSSENT Index'}, {'PX_LAST'}, '04/01/2000', '03/31/2020', 'quarterly');

figure('Name', 'BBG Dividend + BBG Buyback vs BBG EBITDA');
subplot(2, 2, 1);
mdl1 = fitlm(data(:, [5, 30]))
mdl1stats = regstats(data.PAYOUT, data.EBITDA, 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot(data.DATE, data.EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(data.DATE, data.PAYOUT);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Payout', 'EBITDA', 'Location', 'northwest');
title('BBG Dividend + BBG Buyback vs BBG EBITDA');
subplot(2, 2, 2);
plot(mdl1);
subplot(2, 2, 3);
plotResiduals(mdl1);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

figure('Name', 'CIQ Dividend + BBG Buyback vs CIQ EBITDA');
subplot(2, 2, 1);
mdl2 = fitlm(data(:, [19, 31]))
mdl2stats = regstats(data.IQ_PAYOUT, data.IQ_EBITDA, 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot(data.DATE, data.IQ_EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(data.DATE, data.IQ_PAYOUT);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('Payout', 'EBITDA', 'Location', 'northwest');
title('CIQ Dividend + BBG Buyback vs CIQ EBITDA');
subplot(2, 2, 2);
plot(mdl2);
subplot(2, 2, 3);
plotResiduals(mdl2);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

figure('Name', 'BBQ Dividend vs BBG EBITDA and BBG ROC');
subplot(2, 2, 1);
mdl3 = fitlm(data(:, [5, 12, 10]));
mdl3stats = regstats(data.DVD_SH_12M, [data.EBITDA, data.RETURN_ON_CAP], 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot(data.DATE, data.EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(data.DATE, [data.DVD_SH_12M, data.RETURN_ON_CAP]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('EBITDA', 'Dividend', 'ROC', 'Location', 'northwest');
title('BBQ Dividend vs BBG EBITDA and BBG ROC');
subplot(2, 2, 2);
plot( mdl3);
subplot(2, 2, 3);
plotResiduals(mdl3);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

figure('Name', 'CIQ Dividend vs CIQ EBITDA and CIQ ROC');
subplot(2, 2, 1);
mdl4 = fitlm(data(:, [19, 28, 25]));
mdl4stats = regstats(data.IQ_DIV_SHARE, [data.IQ_EBITDA, data.IQ_RETURN_CAPITAL], 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot( data.DATE, data.IQ_EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot( data.DATE, [data.IQ_DIV_SHARE, data.IQ_RETURN_CAPITAL]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('EBITDA', 'Dividend', 'ROC', 'Location', 'northwest');
title('CIQ Dividend vs CIQ EBITDA and CIQ ROC');
subplot(2, 2, 2);
plot(mdl4);
subplot(2, 2, 3);
plotResiduals(mdl4);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

figure('Name', 'CIQ Dividend vs CIQ EBITDA and Adjusted CIQ ROC');
subplot(2, 2, 1);
mdl5 = fitlm(data(:, [19, 31, 25]));
mdl5stats = regstats(data.IQ_DIV_SHARE, [data.IQ_EBITDA, data.IQ_ROC], 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot(data.DATE, data.IQ_EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(data.DATE, [data.IQ_DIV_SHARE, data.IQ_ROC]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('EBITDA', 'Dividend', 'Adjusted ROC', 'Location', 'northwest');
title('CIQ Dividend vs CIQ EBITDA and Adjusted CIQ ROC');
subplot(2, 2, 2);
plot(mdl5);
subplot(2, 2, 3);
plotResiduals(mdl5);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

figure('Name', 'BBG Dividend vs CIQ EBITDA and CIQ ROC');
subplot(2, 2, 1);
mdl6 = fitlm(data(:, [19, 28, 10]));
mdl6stats = regstats(data.DVD_SH_12M, [data.IQ_EBITDA, data.IQ_RETURN_CAPITAL], 'linear', {'yhat', 'r', 'tstat', 'dwstat', 'rsquare'}); %#ok<NASGU>
yyaxis left;
plot(data.DATE, data.IQ_EBITDA);
datetick('x', 'yyyy-mm-dd', 'keepticks');
yyaxis right;
plot(data.DATE, [data.DVD_SH_12M, data.IQ_RETURN_CAPITAL]);
datetick('x', 'yyyy-mm-dd', 'keepticks');
grid on;
legend('EBITDA', 'Dividend', 'ROC', 'Location', 'northwest');
title('CIQ Dividend vs CIQ EBITDA and CIQ ROC');
subplot(2, 2, 2);
plot(mdl6);
subplot(2, 2, 3);
plotResiduals(mdl6);
annotation('textbox', [0.5162, 0.11, 0.4317, 0.3742], 'String', '');

end