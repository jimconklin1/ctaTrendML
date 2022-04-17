function [maxts, mints, locts] =  maxminfinder(h,l,c, lookback, memPeriod)

%__________________________________________________________________________
%
% INPUT
%
% c                   = a matrix of closed price (time-bars x observation)
% lagPeriod           = a structure (1 x n) of time lags
% method:             the user has two methods
% memPeriod is the memory period (usually 1 day)
% - {'and', 'And', 'andMethod', 'AndMethod'}: all breakout MUST have the
%    same direction
% case {'sum', 'Sum', 'sumMethod', 'SumMethod'}: the sum of all breakout
% note: the 'or' method does not have much sense, save as a majoity vote
% rule, which is essentially the sign of the 'sum' method.
% indeed assume 4 breakouts sending the following signals: +1, -1, -1,+1
% 'or' methods will send a flat signal.
% If we have 3 signals: +1, -1, -1, which one prevails? the +1, or the -1.
% Here, the most sensible rule is to use a 'majority vote', hence,
% sign(sum).
%
% OUTPUT
% boLong = matrix of Long breakout
% boShort= matrix of Short breakout
% meanRetLong = average return for Long breakouts
% meanRetShort = average return for Short breakouts
%
%__________________________________________________________________________

% -- Identify Dimensions & Prelocate matrices --
[nsteps,ncols]=size(c);
maxts = zeros(size(c));
mints = zeros(size(c));
locts = zeros(size(c));

% -- Find breakouts --
for j=1:ncols
    cSnap = c(:,j); % snap
    tsStart = StartFinder(cSnap, 'znan'); % find the first cell to start the code
    for i = tsStart + lookback + memPeriod : nsteps
        mints(i,j)=min(l(i-lookback+1-memPeriod:i-memPeriod,j));
        mints(i,j)=max(h(i-lookback+1-memPeriod:i-memPeriod,j));
    end
    midts = (mints(:,j) + maxts(:,j));
    locts(:,j) = c(:,j) ./ midts;
end
    
  