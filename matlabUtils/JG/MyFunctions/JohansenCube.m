function [cj90 cj95 cj99] = JohansenCube(x,PeriodReturn,PeriodCorrelation)
%
%__________________________________________________________________________
%
% This function computes the ratio between:
%       - the (observed) likelihood ratio trace statistics 
%       - and the  (theoretical) critical value 
% for a comination each and any pair of stocks in a universe of n stocks.

% IF the (observed) likelihood ratio trace statistics is greater than the
% (theoretical) critical value THEN we rejects the null hypothesis r<=p.
% Therefore if the ratio is higher than 1, we rejects the null hypothesis
% r<=p
%
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
