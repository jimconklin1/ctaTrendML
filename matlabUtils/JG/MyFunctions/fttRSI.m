%
%__________________________________________________________________________
%
% Fisher transform for rsi
%__________________________________________________________________________
%
function z = fttRSI(rsi)

ct1 = ones(size(rsi));

rsiT = 2 * (rsi-0.5);
rsiTA = 1.5 * rsiT;

rsiTA(rsiTA > 0.999)  = 0.999;
rsiTA(rsiTA < -0.999) = -0.999;

z = 0.5*log(ct1 + rsiTA) ./ (ct1 - rsiTA);
