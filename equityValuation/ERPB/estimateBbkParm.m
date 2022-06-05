function estimateBbkParm(config, data)

startIndex = find(data.OOSDate <= datenum(config.calcStartDate), 1, 'last');
result = zeros(size(data, 1) - startIndex, 12);

seasDum = zeros(size(data, 1), 3);
seasDum(:, 1) = month(data.DataDate) == 3;
seasDum(:, 2) = month(data.DataDate) == 6;
seasDum(:, 3) = month(data.DataDate) == 9;
BBG_BUYBACK = - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
    
for i = startIndex : size(data, 1)
    
    X = [seasDum(2 : i, :), BBG_BUYBACK(1 : i - 1), data.EBITDA(2 : i), data.RETURN_COM_EQY(2 : i)];
    y = BBG_BUYBACK(2 : i);
    mdl = regstats(y, X, 'linear', {'tstat', 'r', 'yhat', 'dwstat', 'rsquare'});

    alpha = mdl.tstat.beta(1);
    alphaQ1 = mdl.tstat.beta(2);
    alphaQ2 = mdl.tstat.beta(3);
    alphaQ3 = mdl.tstat.beta(4);
    beta1 = mdl.tstat.beta(5);
    beta2 = mdl.tstat.beta(6);
    beta3 = mdl.tstat.beta(7);
    % yHat = alpha + X * [alphaQ1; alphaQ2; alphaQ3; beta1; beta2; beta3];
    
    g = (data.REVENUE_PER_SH(i) / data.REVENUE_PER_SH(1)) ^ (4 / i) - 1;
    curve = fit((1 : i)', BBG_BUYBACK(1 : i), strcat('b*(', num2str(1 + g), '^(x/4))'));
    
    result(i + 1 - startIndex, :) = [datenum(data.OOSDate(i)), alpha, alphaQ1, alphaQ2, alphaQ3, beta1, beta2, beta3, mdl.rsquare, mdl.dwstat.dw, curve.b, g];
end

result = array2table(result, 'VariableNames', {'OOSDate', 'Alpha', 'AlphaQ1', 'AlphaQ2', 'AlphaQ3', 'Beta1', 'Beta2', 'Beta3', 'Rsquared', 'DW', 'Baseline', 'Growth'});
result.OOSDate = datestr(result.OOSDate, 'mm/dd/yyyy');
writetable(result, 'bbkProjData.csv', 'Delimiter', ',');

end