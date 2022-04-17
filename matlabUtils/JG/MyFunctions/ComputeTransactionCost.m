%
%__________________________________________________________________________
%
% Function to Set Transaction Cost
%
%__________________________________________________________________________
%

function [Ftc1, Ftc2, Ftc3, Ftc3wgt] = ComputeTransactionCost(i, j, s, wgt, nb)

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