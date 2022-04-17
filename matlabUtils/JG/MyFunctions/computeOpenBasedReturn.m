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

function [grossreturn_i , tcforec_i] = computeOpenBasedReturn(i, j, c, p, s, wgt, loc_rate, usd_rate, DirectionQuote,TC)


% step 1: update parameters for transaction cost
% Adjust transaction cost
    Ftc1=0;% Ftc1 = Factor when Trade Out
    Ftc2=0;% Ftc2 = Factor when Trade In
    Ftc3=0;% Ftc3 = Factor when Nb of shares is different for same signals

    if s(i-1,j)==s(i-2,j);
        Ftc1=0; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif s(i-2,j)==0 && s(i-1,j)~=0
        Ftc1=0; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    elseif s(i-2,j)~=0 && s(i-1,j)==0
        Ftc1=1; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif (s(i-2,j)==1 && s(i-1,j)==-1) || (s(i-2,j)==-1 && s(i-1,j)==1)
        Ftc1=1; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    end   
    % -- Ftc3 for weights-based equity curve --
    if s(i,j) ~= s(i-1,j) || (s(i,j) == s(i-1,j) && wgt(i,j) == wgt(i-1,j)) 
        Ftc3 = 0;
    elseif (s(i,j) == s(i-1,j) && wgt(i,j) ~= wgt(i-1,j)) 
        Ftc3 = 1;
    else
        Ftc3 = 0;
    end
    
% step 2: return & trasnaction cost
if ~isnan(c(i,j)) && ~isnan(c(i-1,j)) && c(i,j)~=0 && c(i-1,j)~=0
    grossreturn_i =  s(i-1,j) * wgt(i-1,j) * (p(i,j)/p(i-1,j) - 1);
    % add carry
    if s(i-1,j)==1
        discountLoc = 0.95; discountUs = 1.05; % penalize lending, increase borrow
    else
        discountLoc = 1.05; discountUs = 0.95; % penalize lending, increase borrow               
    end
    grossreturn_i = grossreturn_i + s(i-1,j) * DirectionQuote(1,j) * (discountUs * usd_rate(i,j) - discountLoc * loc_rate(i,j)) /260;    
    tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
else
    grossreturn_i = 0;  tcforec_i = 0;
end
