function [o,r] = absoluteReturnTest(hrtns,frtns,rfrtns,hHeader,fHeader,outlierThreshold,verbose)

if ~exist('verbose','var')
    verbose = true;
end

y = hrtns - rfrtns/12;
x = frtns - rfrtns/12;

X = [x abs(x)];
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
    fprintf("**********Absolute-Return Regression Results for %s in term of %s**********\n", char(hHeader(1)),char(fHeader(1)));
    fprintf("           Alpha        Beta1       Beta2 \n");
    fprintf("Value:   %f     %f      %f   \n", stats.tstat.beta(1),stats.tstat.beta(2),stats.tstat.beta(3));
    fprintf("t-stat:  %f     %f      %f   \n", stats.tstat.t(1),stats.tstat.t(2),stats.tstat.t(3));
    fprintf("p-value: %f     %f      %f   \n", stats.tstat.pval(1),stats.tstat.pval(2),stats.tstat.pval(3));

    scatter(X(:,1), y, 'b')
    hold on
    x1 = linspace(min(x), max(x));
    plot(x1,beta(1) + beta(2)*x1 +beta(3)*abs(x1) , 'g')
    xlabel(fHeader, 'Interpreter','none')
    ylabel(hHeader, 'Interpreter','none')
    title('Linear Regression on Squared Return (Henriksson and Merton, 1981')
    hold off
end

r = hrtns-beta(3)*X(:,2);
o = [stats.tstat.beta', stats.tstat.pval'];



