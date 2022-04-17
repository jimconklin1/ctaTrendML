%
%__________________________________________________________________________
%
% Function to Compute P&L
% Two different solutions are suggested
% solution 1: it seems to be the most exact solution as when a NDF trade is
% unwound before expiry, one need to enter an opposite NDF trade with same
% expiry.
% solution 2: proxy
% note: the difference between both is not large.
% DirectionQuote
% -1 for XXX/USD
% 1 for USD/XXX
% see spreadsheet FX_NDF_Built_and_PLMethodo.xls
%
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i] = ComputeFxReturnWithDailyFwd(i, j, nextBarDailyFwd, p, ExecP, s, wgt, Ftc1, Ftc2, Ftc3wgt, TC)

if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
    
    % First Day of the trade: factors in Forward Price with the new execution price
    if s(i,j) ~= 0 && s(i,j) ~= s(i-1,j) && ExecP(i-1,j) ~= 0
        grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;
        
    elseif s(i,j) == s(i-1,j) && ExecP(i,j) ~= ExecP(i-1,j) % position has been rolled
        grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;    
        
    elseif s(i,j) == 0 && s(i-1,j) ~=0
        grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j) / nextBarDailyFwd(i-1,j) - 1) ;
        
    else
        grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j) / nextBarDailyFwd(i-1,j) - 1) ;            
    end
    
    tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3wgt*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
    %ec(i,j)=(1+grossreturn(i,j)-tcforec(i,j))*ec(i-1,j);
    
else
    
    grossreturn_i = 0;  tcforec_i = 0;
end
