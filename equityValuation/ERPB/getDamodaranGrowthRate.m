function bbgData = getDamodaranGrowthRate(ticker, startDate, endDate)

% startDate = '1990-01-01';
% endDate = '2020-12-31';
% ticker = 'SPX Index';

if exist('c')~=1 %#ok<EXIST>
   c = blp;
end 
from = datestr(datenum(startDate), 'mm/dd/yyyy');
to = datestr(datenum(endDate), 'mm/dd/yyyy');
bbgData = history(c, {ticker}, {'RETURN_COM_EQY', 'PX_LAST', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EARN_YLD'}, ...
    from, to, {'yearly', 'calendar'}, 'USD');
growthRateLT = history(c, {'CBOPGDNY Index'}, {'PX_LAST'}, from, to, {'yearly', 'calendar'}, 'USD');

earnings = bbgData(:, 3) .* bbgData(:, 7) / 100;
netPayoutRatio = (bbgData(:, 4) - bbgData(:, 5) - bbgData(:, 6)) ./ earnings;
avgROE10 = movmean(bbgData(:, 2), [9 0]);
avgROE10(1 : 9) = 0;
earningsGrowth = zeros(length(earnings), 1);
for i = 10 : length(earnings)
    earningsGrowth(i) = (earnings(i) / earnings(i - 9)) ^ (1 / 9) - 1;
end

epsEstimates = getBbgEstimate(from, to, ticker, 'BEST_EPS', 'yearly');
estimateGrowth = (epsEstimates.FQ8 ./ epsEstimates.FQ1) .^ (4 / 7) - 1;
estimateGrowth7 = (epsEstimates.FQ7 ./ epsEstimates.FQ1) .^ (4 / 6) - 1;
estimateGrowth(isnan(estimateGrowth)) = estimateGrowth7(isnan(estimateGrowth));

bbgData = [bbgData(:, 1), bbgData(:, 2) / 100, bbgData(:, 2) .* (1 - netPayoutRatio) / 100, avgROE10 .* (1 - netPayoutRatio) / 100, earningsGrowth, estimateGrowth, growthRateLT(:,2)/100];

bbgData = array2table(bbgData, 'VariableNames', {'Year', 'ROE', 'FC', 'FA', 'H', 'BU', 'CBO_GDPgrwth'});

end