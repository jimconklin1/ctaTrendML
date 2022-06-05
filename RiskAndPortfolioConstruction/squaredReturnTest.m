function [o,r] = squaredReturnTest(hrtns,frtns,rfrtns,hHeader,fHeader,outlierThreshold,verbose)

if ~exist('verbose','var')
    verbose = true;
end

y = hrtns;
x = frtns;

if ~isempty(rfrtns)
    % TODO: this is asymmetry in the scale of input parameters.
    % To stay out of trouble, these should be on the same scale, in which 
    % case this function could be used for daily/weekly and other scale of
    % returns. The division by 12, when needed, should be outside of this
    % function, before the call is made.  DP 2019-07-31
    % Did not change it because RAPC is not using this feature.
    y = y - rfrtns/12;
    x = x - rfrtns/12;
end % if

X = [x x.*x];
if outlierThreshold >= 100
    stats = regstats(y,X,'linear',{'yhat','tstat'});
else
    weights = robustRegression(y,X,outlierThreshold);
    X1 = X(weights>0,:);
    y1 = y(weights>0);
    stats = regstats(y1,X1,'linear',{'yhat','tstat'});
end

beta = stats.tstat.beta;

if verbose
    fprintf("**********Squared-Return Regression Results for %s in term of %s**********\n", char(hHeader(1)),char(fHeader(1)));
    fprintf("           Alpha        Beta1       Beta2 \n");
    fprintf("Value:   %f     %f      %f   \n", stats.tstat.beta(1),stats.tstat.beta(2),stats.tstat.beta(3));
    fprintf("t-stat:  %f     %f      %f   \n", stats.tstat.t(1),stats.tstat.t(2),stats.tstat.t(3));
    fprintf("p-value: %f     %f      %f   \n", stats.tstat.pval(1),stats.tstat.pval(2),stats.tstat.pval(3));

    scatter(X(:,1), y, 'b')
    hold on
    x1 = linspace(min(x), max(x));
    plot(x1,beta(1) + beta(2)*x1 +beta(3)*x1.*x1 , 'g')
    xlabel(fHeader, 'Interpreter','none')
    ylabel(hHeader, 'Interpreter','none')
    title('Linear Regression on Squared Return (Treynor and Mazury, 1966)')
    hold off
end

r = hrtns-beta(3)*X(:,2);
o = [stats.tstat.beta', stats.tstat.pval'];



