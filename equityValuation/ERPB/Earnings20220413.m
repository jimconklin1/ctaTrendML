inputs = {'PMI', 'Consumer Sentiment', 'Credit Spread', 'Housing Permits', 'GDP'};
tickers = {};
if any(strcmp(inputs, 'PMI'))
    tickers{end + 1} = 'NAPMPMI Index';
end
if any(strcmp(inputs, 'Consumer Sentiment'))
    tickers{end + 1} = 'CONSSENT Index';
end
if any(strcmp(inputs, 'Consumer Confidence'))
    tickers{end + 1} = 'CONCCONF Index';
end
if any(strcmp(inputs, 'Credit Spread'))
    tickers{end + 1} = 'BICLB10Y Index';
end
if any(strcmp(inputs, 'Housing Starts'))
    tickers{end + 1} = 'HSANNHSP Index';
end
if any(strcmp(inputs, 'Housing Permits'))
    tickers{end + 1} = 'NHSPSTOT Index';
end
if any(strcmp(inputs, 'Dollar'))
    tickers{end + 1} = 'DXY Curncy';
end
if any(strcmp(inputs, 'Oil'))
    tickers{end + 1} = 'CL1 Comdty';
end
if any(strcmp(inputs, 'GDP'))
    tickers{end + 1} = 'GDPUNSA Index';
end
if any(strcmp(inputs, 'M2'))
    tickers{end + 1} = 'M2 Index';
end  

c = blp;
from = datestr(datenum('1986-01-01'), 'mm/dd/yyyy');
to = datestr(datenum('2021-12-31'), 'mm/dd/yyyy');
data = history(c, tickers, {'PX_LAST'}, from, to, {'yearly', 'calendar'});

X = [];
for i = 1 : length(data)
    if isempty(X)
        X = data{i}(:,2);
    else
        X(:, end + 1) = data{i}(:,2);
    end
end
X = X(2 : end, :) ./ X(1 : end - 1, :) - 1;
for i = 1 : size(X, 2)
    m = mean(X(:, i));
    s = std(X(:, i));
    X(:, i) = (X(:, i) - m) / s;
end
X(X > 3) = 3;
X(X < -3) = -3;

data = history(c, 'SPX Index', {'TRAIL_12M_EPS'}, from, to, {'yearly', 'calendar'});
% data(:, 3) = 17.64 * exp(0.06246 * (1 : 36));
y = data(2 : end, 2) ./ data(1 : end - 1, 2) - 1;
m = mean(y);
s = std(y);
y = (y - m) / s;
y(y > 3) = 3;
y(y < -3) = -3;

sample_window = 10;
coefficients = zeros(length(y) - sample_window, size(X, 2));
tStats = zeros(length(y) - sample_window, size(X, 2));
rSquared = zeros(length(y) - sample_window, 1);
eps_estimates_a = zeros(length(y) - sample_window, 1);

for i = 1 : (length(y) - sample_window)
    mdl = fitlm(X(i:i+sample_window-1, :), y(i+1:i+sample_window), 'Intercept', false);
    coefficients(i, :) = mdl.Coefficients.Estimate;
    b = mdl.Coefficients.Estimate;
    tStats(i, :) = mdl.Coefficients.tStat;
    rSquared(i) = mdl.Rsquared.Ordinary;
    a = X(i+sample_window, :);
%     m = mean(X(i:i+sample_window-1, :));
%     s = std(X(i:i+sample_window-1, :));
%     cap = m + 2 * s;
%     floor = m - 2 * s;    
%     a(a > cap) = cap(a > cap);
%     a(a < floor) = floor(a < floor);
    z = a * b(1 : end);
    if z > 3
        z = 3;
    elseif z < -3
        z = -3;
    end
    eps_estimates_a(i) = z * s + m;
end
plot(rSquared);
mean(rSquared)
plot(data(2+sample_window:end, 1), data(sample_window+2:end, 2)./data(sample_window+1:end-1, 2)-1, [data(3+sample_window:end, 1); data(end, 1)+365], eps_estimates_a);
legend('Actual', 'Estimates');
