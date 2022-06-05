function bbkForecast = calcBbkForecast(data, ebitdaEst, roeEst)

opts = detectImportOptions('bbkProjData.csv');
opts = setvaropts(opts, 'OOSDate', 'InputFormat', 'MM/dd/yyyy');
parameters = readtable('bbkProjData.csv', opts);
parameters.OOSDate = datenum(parameters.OOSDate);
bbkForecast = nan(size(ebitdaEst, 1), 401);
bbkForecast(:, 1) = ebitdaEst.CalcDate;

    function forecasts = calcBbk128Q(calcDate)
        
        oosDate = max(data.OOSDate(calcDate > data.OOSDate)); % closest available Bloomberg data to calculation date
        index = find(datenum(data.OOSDate) == oosDate);
        
        oosDate = max(parameters.OOSDate(calcDate > parameters.OOSDate)); % closest available estimation data to calculation date
        idx = find(parameters.OOSDate == oosDate);
        alpha = parameters.Alpha(idx);
        alphaQ1 = parameters.AlphaQ1(idx);
        alphaQ2 = parameters.AlphaQ2(idx);
        alphaQ3 = parameters.AlphaQ3(idx);
        beta1 = parameters.Beta1(idx);
        beta2 = parameters.Beta2(idx);
        beta3 = parameters.Beta3(idx);
        baseline = parameters.Baseline(idx);
        growth = parameters.Growth(idx);
        
        forecasts = zeros(1, 400);
        for j = 1 : 8 % eight quarters of estimates
            x1 = quarter(addtodate(calcDate, 3 * (j - 1), 'month')) == 1; % sample values for all eight j: 1 0 0 0 1 0 0 0
            x2 = quarter(addtodate(calcDate, 3 * (j - 1), 'month')) == 2; % sample values for all eight j: 0 1 0 0 0 1 0 0
            x3 = quarter(addtodate(calcDate, 3 * (j - 1), 'month')) == 3; % sample values for all eight j: 0 0 1 0 0 0 1 0
            if j == 1
                x4 = - data.CF_DECR_CAP_STOCK(index) - data.CF_INCR_CAP_STOCK(index);
            else
                x4 = forecasts(j - 1 );
            end
            x5 = table2array(ebitdaEst(find(ebitdaEst.CalcDate <= calcDate, 1, 'last'), j + 1));
            x6 = table2array(roeEst(find(roeEst.CalcDate <= calcDate, 1, 'last'), j + 1));
            if isnan(x6)
                x6 = data.RETURN_COM_EQY(index);
            end
            forecasts(j) = alpha + x1 * alphaQ1 + x2 * alphaQ2 + x3 * alphaQ3 + x4 * beta1 + x5 * beta2 + x6 * beta3;
        end
        
        for j = 40 : 400
            forecasts(j) = baseline * ((1 + growth) ^ (j / 4));
        end
        
        n = find(isnan(forecasts), 1);
        if isempty(n)
            n = 9;
        end
        growth2 = (forecasts(40) / forecasts(n - 1)) ^ (4 / (40 - (n - 1))) - 1;
        for j = n : 39
            forecasts(j) = forecasts(n - 1) * (1 + growth2) ^ ((j - (n - 1)) / 4);
        end
        
    end

for i = 1 : size(bbkForecast, 1)
    bbkForecast(i, 2 : 401) = calcBbk128Q(bbkForecast(i, 1));
end

% bbkForecast = array2table(bbkForecast, 'VariableNames', {'CalcDate', 'FQ1', 'FQ2', 'FQ3', 'FQ4', 'FQ5', 'FQ6', 'FQ7', 'FQ8'});
% data.Actual = - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
% bbkForecast = bbkForecast([1 : 50] * 3 - 1, :);
% plotForecast(data, bbkForecast);
% bbkForecast.CalcDate = datestr(bbkForecast.CalcDate, 'mm/dd/yyyy');

end