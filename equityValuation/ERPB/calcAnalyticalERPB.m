function erpb = calcAnalyticalERPB(config)

c = blp;
indexData = history(c, config.indexId, {'PX_LAST', 'EARN_YLD', 'EQY_DVD_YLD_12M'}, config.calcStartDate, config.calcEndDate, config.caclFreq);
bondData = history(c, 'GTUSD30Y Govt', {'PX_LAST'}, config.calcStartDate, config.calcEndDate, config.caclFreq);

data = [indexData(:, [1, 2]), indexData(:, [3, 4]) / 100, bondData(:, 2) / 100];
data(:, 6) = data(:, 4) + data(:, 3) * config.nonDivPO2earn;
data(:, 7) = (1 + config.nomGrwth) ./ (1 - data(:, 6)) - 1 - data(:, 5);

erpb = array2table(data, 'VariableNames', {'CalcDate', 'Index', 'EarnYld', 'DivYld', 'Bond30Yld', 'POYld', 'ERPB'});

figure;
yyaxis left;
plot(erpb.CalcDate, [erpb.ERPB, erpb.Bond30Yld], 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([data(1, 1), data(end, 1)]);
%ylim([0, 0.09]);
y = cellstr(num2str(get(gca, 'ytick')' * 100));
pct = char(ones(size(y, 1), 1) * '%'); 
new_yticks = [char(y), pct];
set(gca, 'yticklabel', new_yticks);

yyaxis right;
plot(erpb.CalcDate, erpb.Index, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([data(1, 1), data(end, 1)]);
%ylim([1600, 3400]);

label = split(config.indexId, ' ');
set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend(strcat(label{1}, ' ERPB'), '30Y US Govt YTM', strcat(label{1}, ' (RHS)'), 'Location', 'northwest');
title(strcat(config.indexId, ' ERPB'));

end