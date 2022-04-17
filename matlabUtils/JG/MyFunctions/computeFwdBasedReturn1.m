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

function [grossreturn_i , tcforec_i] = computeFwdBasedReturn1(i, c, p, pfwd, s, wgt, DirectionQuote, TC)


% -- dimensions & prelocation of matrices --
[nsteps,ncols]=size(c);
grossreturn_i = zeros(1,ncols); 
tcforec_i = zeros(1,ncols);  

for j=1:ncols    

    % step 2: return & transaction cost
    if ~isnan(c(i,j)) && ~isnan(c(i-1,j)) && c(i,j)~=0 && c(i-1,j)~=0
        grossreturn_i(1,j) =  s(i-1,j) * wgt(i-1,j) * (p(i,j)/pfwd(i-1,j) - 1);  
        tcforec_i = TC(1,j) * abs(s(i-1,j)*wgt(i-1,j) - s(i-2,j)*wgt(i-2,j));
    else
        grossreturn_i(1,j) = 0; 
        tcforec_i(1,j) = 0;
    end

end            
