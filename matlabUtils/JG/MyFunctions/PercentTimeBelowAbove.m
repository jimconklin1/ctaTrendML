function [pbelow,pabove] = PercentTimeBelowAbove(c,MAlookback, method)
%__________________________________________________________________________
%
% Compute the number of time below or above a moving average
% Joel Guglietta - February 2014
%__________________________________________________________________________

% -- Dimension & Prelocation --
[nsteps, ncols] = size(c);
pbelow = zeros(size(c));
pabove = zeros(size(c));
     
pbelow = zeros(size(c));
pabove = zeros(size(c));

switch method
    case {'tri', 'triangular', 'trima'}
        ma = expmav(c , MAlookback);
    case {'arithmetic', 'simple', 'arith', 'ama'}
        ma = arithmav(c , MAlookback);
    case {'exponential' , 'expmav', 'exp'}
        ma = triangularmav(c , MAlookback);
end

signdif = sign(c-ma);

MinNbPoint2StartWith = 30;

for j=1:ncols
    % initialize
    sumcount_neg = 0;
    sumcount_pos = 0;
    for i=MinNbPoint2StartWith:nsteps
        if signdif(i,j) < 0
            sumcount_neg = sumcount_neg + 1;
            pbelow(i,j) = sumcount_neg/i;
        else
            pbelow(i,j) = pbelow(i-1,j);
        end
        if signdif(i,j) > 0
            sumcount_pos = sumcount_pos + 1;
            pabove(i,j) = sumcount_pos/i;
        else
            pabove(i,j) = pabove(i-1,j);
        end
    end
end            