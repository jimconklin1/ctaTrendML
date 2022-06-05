function estimateDivParm(config, data)

startIndex = find(data.OOSDate <= datenum(config.calcStartDate), 1, 'last');
result = nan(size(data, 1) - startIndex, 9);

% IQ_EBIT = data.IQ_EBITDA .* data.IQ_TEV ./ data.IQ_LASTSALEPRICE;
% IQ_DIV_SHARE = data.IQ_DIV_SHARE .* data.IQ_TEV ./ data.IQ_LASTSALEPRICE;

for i = startIndex : size(data, 1)    
    x1 = (data.EBITDA(4:i) - data.EBITDA(3:i-1)) ./ data.EBITDA(3:i-1);
    x2 = (data.EBITDA(3:i-1) - data.EBITDA(2:i-2)) ./ data.EBITDA(2:i-2);
    x3 = (data.EBITDA(2:i-2) - data.EBITDA(1:i-3)) ./ data.EBITDA(1:i-3);
    y = (data.DVD_SH_12M(4:i) - data.DVD_SH_12M(3:i-1)) ./ data.DVD_SH_12M(3:i-1);

    mdl = regstats(y, [x1, x2, x3], 'linear', {'tstat', 'r', 'yhat', 'dwstat', 'rsquare'});
    alpha = mdl.tstat.beta(1);
    beta1 = mdl.tstat.beta(2);
    beta2 = mdl.tstat.beta(3);
    beta3 = mdl.tstat.beta(4);
    % yHat = data.DVD_SH_12M(3:i-1) + (alpha + beta1 * x1 + beta2 * x2 + beta3 * x3) .* data.DVD_SH_12M(3:i-1);
    resids = mdl.r .* data.DVD_SH_12M(3:i-1);
    rSqrd = 1 - var(resids) / var(data.DVD_SH_12M(4:i));
    
    g = (data.REVENUE_PER_SH(i) / data.REVENUE_PER_SH(1)) ^ (4 / i) - 1;
    curve = fit((1:i)', data.DVD_SH_12M(1:i), strcat('b*(', num2str(1 + g), '^(x/4))'));
    
    result(i + 1 - startIndex, :) = [data.OOSDate(i), alpha, beta1, beta2, beta3, rSqrd, mdl.dwstat.dw, curve.b, g];
end

result = array2table(result, 'VariableNames', {'OOSDate', 'Alpha', 'Beta1', 'Beta2', 'Beta3', 'Rsquared', 'DW', 'Baseline', 'Growth'});
result.OOSDate = datestr(result.OOSDate, 'mm/dd/yyyy');
writetable(result, 'divProjData.csv', 'Delimiter', ',');

end