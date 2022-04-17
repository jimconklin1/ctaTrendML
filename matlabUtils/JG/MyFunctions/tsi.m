function y = tsi(c,h,l, period_return, period_atr)
%
%--------------------------------------------------------------------------
%
% TSI is Trend Strength Index

% TSI is an indicator designed to identify true trend strength.
% A high TSI value indicates that short-term trend continuation 
% (follow through) is more likely than short-term trend reversal
% (mean reversion). For e.g., NASDAQ100 stocks with a value of greater than
% 1.65 indicate a healthy trend environment.
% -- Input --
% period_return: the period for the ATR and the return
% period_atr: the period for the smoothing device
% -- Output --
% y = the TSI
%--------------------------------------------------------------------------
%
%
% -- ATR & x-day difference in Close Price --
atr = ATRFunction(c,h,l,period_atr,3);
dif = Delta(c,'dif',period_return);
% -- Trend Strength Index --
y = (dif) ./ atr;
% -- Clean --
[nsteps,ncols]=size(c);
for j=1:ncols
    % Find first non empty
    %start_date=zeros(1,1);
    %for i=1:nsteps
    %    if ~isnan(y(i,j))
    %        start_date(1,1)=i;
    %    break               
    %    end                                 
    %end    
    for i=1:nsteps
        if isnan(y(i,j)), y(i,j) = 0; end
    end
end

