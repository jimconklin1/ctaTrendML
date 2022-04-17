%
%__________________________________________________________________________
%
% Function to Compute P&L at the stock / Future level
% Step 1 adjust the transaction cost
% Step 2 compute the P&L
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i] = ComputeDayPL(i, j, o, c, s, wgt, nb, TC, method)
%
% -- Step 1: Process to compute transaction Cost --   
Ftc1=0; Ftc2=0; Ftc3=0;
% Ftc1 = Factor when Trade Out
% Ftc2 = Factor when Trade In
% Ftc3 = Factor when Nb of shares is different for same signals
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
% -- Ftc3 for nb.-of-shares-based P&L --
if s(i,j)~=s(i-1,j) || (s(i,j)==s(i-1,j) && nb(i,j)==nb(i-1,j))
    Ftc3=0;
elseif (s(i,j)==s(i-1,j) && nb(i,j)~=nb(i-1,j)) 
    Ftc3=1;
else
    Ftc3=0;
end
% -- Ftc3 for weights-based equity curve --
if s(i,j) ~= s(i-1,j) || (s(i,j) == s(i-1,j) && wgt(i,j) == wgt(i-1,j)) 
    Ftc3wgt = 0;
elseif (s(i,j) == s(i-1,j) && wgt(i,j) ~= wgt(i-1,j)) 
    Ftc3wgt = 1;
else
    Ftc3wgt = 0;
end 
%
% -- Step 2: Stock/Future P&L
if ~isnan(o(i,j)) && ~isnan(c(i,j)) && o(i,j)~=0 && c(i,j)~=0
    switch method
        case {'o2c', 'open-to-close', 'open-2-close', 'open2close'}
            grossreturn_i = s(i-1,j) * wgt(i-1,j) * (c(i,j)/o(i,j)-1) ;
        case {'c2c', 'close-to-close', 'close-2-close', 'close2close'}
            grossreturn_i = s(i-1,j) * wgt(i-1,j) * (c(i,j)/c(i-1,j)-1) ;
    end
    tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3wgt*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb  
else
    grossreturn_i = 0;  tcforec_i = 0;
end    
