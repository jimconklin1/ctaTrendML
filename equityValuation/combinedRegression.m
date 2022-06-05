ciqData = readtable('Data.csv');
ciqData.IQ_PAYOUT = ciqData.IQ_DIV_SHARE - ciqData.CF_DECR_CAP_STOCK - ciqData.CF_INCR_CAP_STOCK;

INCOME_STATEMENT = 6 : 14;
BALANCE_SHEET = 15 : 22;
CASH_FLOW = 23 : 25;
RATIOS = 26 : 31;

results = cell(length(INCOME_STATEMENT) * length(BALANCE_SHEET) * length(CASH_FLOW) * length(RATIOS), 11);
m = 0;

for i = 1 : length(INCOME_STATEMENT)
    for j = 1 : length(BALANCE_SHEET)
        for k = 1 : length(CASH_FLOW)
            for l = 1 : length(RATIOS)
                m = m + 1;
                mdl = fitlm([ciqData(:, INCOME_STATEMENT(i)), ciqData(:, BALANCE_SHEET(j)), ciqData(:, CASH_FLOW(k)), ciqData(:, RATIOS(l)), ciqData(:, end)], 'Intercept', false);
                results(m, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
                results(m, 2) = num2cell(mdl.Rsquared.Ordinary);
                results(m, 3) = num2cell(dwtest(mdl));
                results(m, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
                results(m, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
                results(m, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
                results(m, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
                results(m, 8) = num2cell(table2array(mdl.Coefficients(3, 1)));
                results(m, 9) = num2cell(table2array(mdl.Coefficients(3, 3)));
                results(m, 10) = num2cell(table2array(mdl.Coefficients(4, 1)));
                results(m, 11) = num2cell(table2array(mdl.Coefficients(4, 3)));
            end
        end
    end
end