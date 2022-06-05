function o = dualBetaTest(hrtns,frtns,rfrtns,hHeader,fHeader,outlierThreshold,verbose)

if ~exist('verbose','var')
    verbose = true;
end

hrtns = hrtns - rfrtns/12;
frtns = frtns - rfrtns/12;

maskPartition = frtns >= 0;

partition1 = fitlm(frtns(maskPartition),hrtns(maskPartition));
partition2 = fitlm(frtns(~maskPartition),hrtns(~maskPartition));



coef1 = partition1.Coefficients.Estimate;
coef2 = partition2.Coefficients.Estimate;

X1 = [ones(length(frtns(maskPartition)),1) frtns(maskPartition)];
X2 = [ones(length(frtns(~maskPartition)),1) frtns(~maskPartition)];

yCalc1 = X1*coef1;
yCalc2 = X2*coef2;

%The Z-score is 0.6249, which is smaller than 1.64 that corresponds to the 0.05 significance level.
%Therefore, we do not reject the H0.
testResult = (coef1(2)-coef2(2)) / sqrt(partition1.Coefficients.SE(2)^2 + partition2.Coefficients.SE(2)^2);
testCritVal = icdf(makedist('Normal'), 0.95);
pval = 1 - normcdf(testResult);

if verbose
    fprintf("**********Dual-Beta Test Results for %s in term of %s**********\n", char(hHeader(1)),char(fHeader(1)));

    partition1
    partition2

    scatter(frtns(maskPartition), hrtns(maskPartition), 'b')
    hold on
    scatter(frtns(~maskPartition), hrtns(~maskPartition), 'r')
    plot(frtns(maskPartition), yCalc1, 'b')
    plot(frtns(~maskPartition), yCalc2, 'r')
    %plot(frtns(maskPartition), yCalc3, 'g')
    %plot(frtns(~maskPartition), yCalc4, 'k')
    %legend('Partition +', 'Partition -', 'LR + (with interc)', 'LR - (with interc)', 'LR +', 'LR -')
    legend('Partition +', 'Partition -', 'LR +', 'LR -')
    xlabel(fHeader, 'Interpreter','none')
    ylabel(hHeader, 'Interpreter','none')
    title('Linear Regression on Two Partitions')
    hold off

    fprintf('\n');
    fprintf('Testing following hypothesis on beta parameters from regressions on two partitions');
    fprintf('\n');
    fprintf('H0:  b1 – b2 = 0');
    fprintf('\n');
    fprintf('HA: b1 – b2 > 0');
    fprintf('\n');
    fprintf('The Z-score is %.02f , critical value is %.02f.', testResult, testCritVal);
    fprintf('\n');
    if (testResult < testCritVal)
        fprintf('We do not reject null hypothesis.');
    else
        fprintf('We reject null hypothesis.');
    end
    fprintf('\n');
end

o = [coef1', coef2', pval];
