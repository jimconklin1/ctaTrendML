c = blp;

variableNames = {'Date', 'PX_LAST', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', ...
    'PE_RATIO', 'PX_TO_BOOK_RATIO', 'EV_TO_T12M_SALES', 'EV_TO_T12M_EBIT', 'EV_TO_T12M_EBITDA', 'EQY_DVD_YLD_12M', ... % Valuation Highlights
    'TRAIL_12M_GROSS_MARGIN', 'TRAIL_12M_OPER_MARGIN', 'TRAIL_12M_PROF_MARGIN', 'RETURN_ON_ASSET', 'RETURN_COM_EQY', ... % Fundamental Highlights
    'PX_TO_CASH_FLOW', 'PX_TO_SALES_RATIO', 'PX_TO_EBITDA', 'FREE_CASH_FLOW_YIELD', ... % Valuation
    'EBITDA_MARGIN', 'RETURN_ON_CAP', 'DVD_PAYOUT_RATIO', 'ACTUAL_SALES_PER_EMPL', ... % Profitability
    'CUR_RATIO', 'NET_DEBT_TO_EBITDA', 'TOTAL_DEBT_TO_CURRENT_EV', 'TOT_DEBT_TO_TOT_EQY', 'TOT_DEBT_TO_TOT_ASSET', ... % Leverage & Liquidity
    'PX_VOLUME', 'FREE_FLOAT_MARKET_CAP', ... % Market Data
    'TRAIL_12M_SALES_PER_SH', 'OPER_INC_PER_SH', 'EBITDA', 'TRAIL_12M_EPS', ... % Income Statement
    'CASH_FLOW_PER_SH', 'CAPITAL_EXPEND', 'FREE_CASH_FLOW_PER_SH', ... % Cash Flow
    'CASH_ST_INVESTMENTS_PER_SH', 'BS_CUR_ASSET_REPORT', 'BS_TOT_ASSET', 'BS_CUR_LIAB',...
    'SHORT_AND_LONG_TERM_DEBT', 'BS_TOT_LIAB2', 'BS_RETAIN_EARN', 'BOOK_VAL_PER_SH', 'TANG_BOOK_VAL_PER_SH', 'TOTAL_EQUITY', 'ENTERPRISE_VALUE'}; % Balance Sheet
    
data1 = history(c, {'SPX Index'}, variableNames(2:19), '01/01/1997', '03/31/2020', 'quarterly', 'USD', 'overridefields', {'FUND_PER', 'Q'});
data2 = history(c, {'SPX Index'}, variableNames(20:37), '01/01/1997', '03/31/2020', 'quarterly', 'USD', 'overridefields', {'FUND_PER', 'Q'});    
data3 = history(c, {'SPX Index'}, variableNames(38:49), '01/01/1997', '03/31/2020', 'quarterly', 'USD', 'overridefields', {'FUND_PER', 'Q'});

data = [data1, data2(:, 2:end), data3(:, 2:end)];
data = array2table(data, 'VariableNames', variableNames);
data.PAYOUT = data.DVD_SH_12M - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;

results = cell(length(variableNames) - 5, 7);
for i = 6 : length(variableNames)
    mdl = fitlm([data(:, i), data(:, end)], 'Intercept', false);
    % mdl = fitlm([data(:, i), data(:, end)], 'Intercept', false);
    results(i - 5, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
    results(i - 5, 2) = num2cell(mdl.Rsquared.Ordinary);
    results(i - 5, 3) = num2cell(dwtest(mdl));
    results(i - 5, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
    results(i - 5, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
    %results(i - 5, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
    %results(i - 5, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
end

results2 = cell((length(variableNames) - 5) * (length(variableNames) - 6) / 2, 7);
k = 0;
for i = 6 : (length(variableNames) - 1)
    for j = (i + 1) : length(variableNames)
        k = k + 1;
        mdl = fitlm([data(:, i), data(:, j), data(:, end)], 'Intercept', false);
        results2(k, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
        results2(k, 2) = num2cell(mdl.Rsquared.Ordinary);
        results2(k, 3) = num2cell(dwtest(mdl));
        results2(k, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
        results2(k, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
        results2(k, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
        results2(k, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
    end
end

ciqData = readtable('Data.csv');
ciqData.IQ_PAYOUT = ciqData.IQ_DIV_SHARE - ciqData.CF_DECR_CAP_STOCK - ciqData.CF_INCR_CAP_STOCK;

results3 = cell(size(ciqData, 2) - 6, 7);
for i = 6 : size(ciqData, 2) - 1
    mdl = fitlm([ciqData(:, i), data(14:end, end)], 'Intercept', false);
    results3(i - 5, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
    results3(i - 5, 2) = num2cell(mdl.Rsquared.Ordinary);
    results3(i - 5, 3) = num2cell(dwtest(mdl));
    results3(i - 5, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
    results3(i - 5, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
    %results3(i - 5, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
    %results3(i - 5, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
end

results4 = cell((size(ciqData, 2) - 5) * (size(ciqData, 2) - 6) / 2, 7);
k = 0;
for i = 6 : (size(ciqData, 2) - 2)
    for j = (i + 1) : (size(ciqData, 2) - 1)
        k = k + 1;
        mdl = fitlm([ciqData(:, i), ciqData(:, j), data(14:end, end)], 'Intercept', false);
        results4(k, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
        results4(k, 2) = num2cell(mdl.Rsquared.Ordinary);
        results4(k, 3) = num2cell(dwtest(mdl));
        results4(k, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
        results4(k, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
        results4(k, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
        results4(k, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
    end
end

results5 = cell(20000, 9);
l = 0;
for i = 6 : (size(ciqData, 2) - 3)
    for j = (i + 1) : (size(ciqData, 2) - 2)
        for k = (j + 1) : (size(ciqData, 2) - 1)
            l = l + 1;
            mdl = fitlm([ciqData(:, i), ciqData(:, j), ciqData(:, k), ciqData(:, end)], 'Intercept', false);
            results5(l, 1) = {strcat(mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor)};
            results5(l, 2) = num2cell(mdl.Rsquared.Ordinary);
            results5(l, 3) = num2cell(dwtest(mdl));
            results5(l, 4) = num2cell(table2array(mdl.Coefficients(1, 1)));
            results5(l, 5) = num2cell(table2array(mdl.Coefficients(1, 3)));
            results5(l, 6) = num2cell(table2array(mdl.Coefficients(2, 1)));
            results5(l, 7) = num2cell(table2array(mdl.Coefficients(2, 3)));
            results5(l, 8) = num2cell(table2array(mdl.Coefficients(3, 1)));
            results5(l, 9) = num2cell(table2array(mdl.Coefficients(3, 3)));
        end
    end
end