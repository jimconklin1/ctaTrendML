function y = skew(x,Period)
%__________________________________________________________________________
% The function computes the Volatility of a stock in several different ways
%
% - 'simple volatility' :       
%       standard deviation of the price
%__________________________________________________________________________
%
% -- Standard Deviation --
%[sigma,masigma] = VolatilityFunction(x,method,Period,PeriodAvgPrice,Troncate);
% -- Third Moment --
%ma = arithmav(x,Period);
%ma3  = ma .* ma .* ma;
%
y = zeros(size(x));
[nbsteps,nbcols]=size(y);
for j=1:nbcols
    % find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(x(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Moving average
    for k=start_date(1,1)+Period-1:nbsteps
        y(k,j)=skewness(x(k-Period+1:k,j));
    end
end

