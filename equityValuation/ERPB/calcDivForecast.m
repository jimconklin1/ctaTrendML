function divForecast = calcDivForecast(data, ebitdaEst)

opts = detectImportOptions('divProjData.csv');
opts = setvaropts(opts, 'OOSDate', 'InputFormat', 'MM/dd/yyyy');
parameters = readtable('divProjData.csv', opts);
parameters.OOSDate = datenum(parameters.OOSDate);
divForecast = nan(size(ebitdaEst, 1), 401);
divForecast(:, 1) = ebitdaEst.CalcDate;

    function forecasts = calcDiv128Q(calcDate)
        
        oosDate = max(data.OOSDate(calcDate > data.OOSDate)); % closest available Bloomberg data to calculation date
        index = find(datenum(data.OOSDate) == oosDate);
        ebitda = [data.EBITDA(1 : index); table2array(ebitdaEst(ebitdaEst.CalcDate == calcDate, 2 : end))']; % 1 ... index is historical quarterly data, following that are eight quarters of estimates
        
        oosDate = max(parameters.OOSDate(calcDate > parameters.OOSDate)); % closest available etimateion data to calculation date
        idx = find(parameters.OOSDate == oosDate);
        alpha = parameters.Alpha(idx);
        beta1 = parameters.Beta1(idx);
        beta2 = parameters.Beta2(idx);
        beta3 = parameters.Beta3(idx);
        baseline = parameters.Baseline(idx);
        growth = parameters.Growth(idx);
        
        forecasts = zeros(1, 400);
        for j = 1 : 8 % eight quarters of esimates
            x1 = (ebitda(index + j) - ebitda(index + j - 1)) / ebitda(index + j - 1);
            x2 = (ebitda(index + j - 1) - ebitda(index + j - 2)) / ebitda(index + j - 2);
            x3 = (ebitda(index + j - 2) - ebitda(index + j - 3)) / ebitda(index + j - 3);
            if j == 1
                div_t_1 = data.DVD_SH_12M(index);
            else
                div_t_1 = forecasts(j - 1 );
            end
            forecasts(j) = div_t_1 + (alpha + beta1 * x1 +  beta2 * x2 +  beta3 * x3) .* div_t_1;
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

for i = 1 : size(divForecast, 1)
    divForecast(i, 2 : 401) = calcDiv128Q(divForecast(i, 1));
end

% divForecast = array2table(divForecast, 'VariableNames', {'CalcDate', 'FQ1', 'FQ2', 'FQ3', 'FQ4', 'FQ5', 'FQ6', 'FQ7', 'FQ8'});
% data.Actual = data.DVD_SH_12M;
% divForecast = divForecast([1 : 50] * 3 - 1, :);
% plotForecast(data, divForecast);
% divForecast.CalcDate = datestr(divForecast.CalcDate, 'mm/dd/yyyy');

end