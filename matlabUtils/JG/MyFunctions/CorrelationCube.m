function y = CorrelationCube(x,PeriodReturn,PeriodCorrelation)
%
%__________________________________________________________________________
%
%The function computes the corelatiion of a n*p matrix (n assets, p
%observations)
% INPUT--------------------------------------------------------------------
% X = matrix of price
% 'method'is :
% - 'PeriodReturn'          : if PeriodReturn==0 then use levels, 
%                               else, use the return.
% - 'PeriodCorrelation'     :   period for rate of change
% OUTPUT--------------------------------------------------------------------
% y : cube of correlation matrix
% nte: should compute the significance level of correlation too dude!
%__________________________________________________________________________

% Define dimension & Prelocate matrix
[nsteps,ncols] = size(x); 
y = zeros(ncols,ncols,nsteps);

if PeriodReturn>0
    x=RateofChange(x,'rate of change',PeriodReturn);
end
    
for i=PeriodCorrelation+PeriodReturn:nsteps
    Corr_i=corr(x(i-PeriodCorrelation+1:i,:));
    y(:,:,i)=Corr_i;
end    
