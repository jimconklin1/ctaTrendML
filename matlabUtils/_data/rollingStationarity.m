
function [adfv, pv, halflife] = rollingStationarity(x, period)

addpath 'H:\GIT\matlabUtils\_spatial_econometrics\';

% Dimension & prelocation
[nsteps,ncols] = size(x);
adfv = zeros(size(x));
pv = zeros(size(x));
halflife = zeros(size(x));

for j=1:ncols
    % Snap the price
    xJ = x(:,j);
    tsStart = StartFinder(xJ, 'Non-zero');
    for i = tsStart + period : nsteps
        % Assume a non-zero offset but no drift, with lag=1.
        xJSnap = xJ(i-period+1:i);
        % Run ADF
        results = adf(xJSnap, 0, 1); % adf is a function in the jplv7 (spatial-econometrics.com) package.
        adfv(i,j) = real(results.adf);
        pv(i,j) = results.crit(2,1);
        % Find value of lambda and thus the halflife of mean reversion by linear regression fit
        xJSnaplag=lag(xJSnap, 1);  % lag is a function in the jplv7 (spatial-econometrics.com) package.
        deltaxJSnap=xJSnap-xJSnaplag;
        deltaxJSnap(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
        xJSnaplag(1)=[];
        regress_results=ols(deltaxJSnap, [xJSnaplag ones(size(xJSnaplag))]); % ols is a function in the jplv7 (spatial-econometrics.com) package.
        halflife(i,j) = -log(2)/regress_results.beta(1);
        % fprintf(1, 'halflife=%f days\n', halflife);
    end
end

