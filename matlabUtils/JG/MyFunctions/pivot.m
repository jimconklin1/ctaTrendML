function [hpp, lpp] = pivot(h,l,c)
%
%__________________________________________________________________________
%
% Computes Pivot ranges in order to establish a bullish or bearish bias
%
% note: If the previous close was above today's pivot range hogh, then
%       prices are considered bullish;
%       if below the pibot low then it is bearish.
%       To confirm a bullish bias, today's price movement must find support
%       at the daily pivot low and not trade below that level.
%       If prices break through the pivot low, they are expected to make a
%       significant move lower; therefore, the pivot range acts as a strong
%       support an resistance.
%__________________________________________________________________________
%
%
[nsteps,ncols]=size(c);
hpp = zeros(size(c));
lpp = zeros(size(c));

% Daily Pivot Price
%dpp = (h+l+c)/3;
% Average High-Low
%ahl = (h+l)/2;
% Daily Price Differential
%dpd = dpp - ahl;
% Daily Pivot High
%dph = dpp + dpd;
% Daily Pivot Low
%dpl = dpp - dpd;

for j=1:ncols
    for i=3:nsteps
        if l(i-1,j) < l(i-2,j) && l(i-1,j) > l(i,j)
            lpp(i,j) = l(i-1,j);
        end
    end
    for i=3:nsteps
        if h(i-1,j) > h(i-2,j) && h(i-1,j) < h(i,j)
            hpp(i,j) = h(i-1,j);
        end
    end
end
        
        
