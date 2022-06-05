function erpb = calcPerturbationERPB(zeroRates, bbgData, dividend, buyback)

erpb = zeros(size(dividend, 1), 1);
for i = 1 : size(dividend, 1)
	erpb(i) = calcERPB(zeroRates, bbgData, dividend(i, :), buyback(i, :));
end

for i = 1 : length(erpb)
    if erpb(i) > 10
        fprintf('Smoothing ERPB at %s due to negative forward payout projection.\n', datestr(bbgData.DataDate(i)));
        erpb(i) = (erpb(i - 1) + erpb(i + 1)) / 2;
    end
end

figure;
yyaxis left;
plot(zeroRates.CalcDate, [erpb, table2array(zeroRates(:, end))], 'LineWidth', 2);
yyaxis right;
plot(bbgData.CalcDate, bbgData.PX_LAST, 'LineWidth', 2);
datetick('x', 'yyyy-mm-dd', 'keepticks');
xlim([dividend(1, 1), dividend(end, 1)]);

set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend('SPX ERPB', '30Y Zero Rate', 'SPX (RHS)', 'Location', 'northwest');
title('US Equity Valuation');

erpb = array2table([dividend(:, 1), erpb, table2array(zeroRates(:, end)), bbgData.PX_LAST], 'VariableNames', {'CalcDate', 'ERPB', 'Bond30Y', 'SPX'});

end