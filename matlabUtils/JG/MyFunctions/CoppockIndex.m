function sy = CoppockIndex(h, l, maperiod, lookback, method)
%
%__________________________________________________________________________
%
% This function computes the Coppock Indicator based on mid-price.
% INPUT....................................................................
% h,l                 = highs & lows
% note: calibration is (http://en.wikipedia.org/wiki/Coppock_curve) usually
% a long-term indicator for period in month
% Parameters(1,1)   = 14 (13)
% OUTPUT...................................................................
% y = Coppock Indicator 
%__________________________________________________________________________
%
% Compute Indicator--------------------------------------------------------
[nsteps,ncols] = size(h);
y = zeros(size(h));
sy = zeros(size(h));
mp = (h+l) / 2; % mid-price

switch method
    case{'ema' , 'expma'}
        mamp = expmav(mp,maperiod);
    case{'ama' , 'arithma'}
        mamp = expmav(mp,maperiod);
    case {'tma', 'triangma'}
        mamp = tirnagularmaav(mp,maperiod);
end
difmpmamp = mp-mamp;

for i=2:nsteps
    for j =1:ncols
        if sign(difmpmamp(i,j)) ~= sign(difmpmamp(i-1,j))
            y(i,j) = 1;
        else
            y(i,j) = 0;
        end
    end
end

for i=lookback:nsteps
    for j =1:ncols
        sy(i,j) = sum(y(i-lookback+1:i,j));
    end
end
