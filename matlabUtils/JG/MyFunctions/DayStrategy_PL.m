%
%__________________________________________________________________________
%
% Function to Compute P&L at the stock / Future level
% Signal at yesterday close, execution at today open, exit at today close
%    {'syc_to2tc'}
% Signal at yesterday close, execution at yesterday close, exit at today close
%    {'syc_yc2tc'}
% Signal at yesterday close, execution at yesterday close, exit at today open
%    {'syc_yc2to'}
% Signal at today open, execution at today open, exit at today close
%    {'sto_to2tc'}
%__________________________________________________________________________
%

function [grossreturn_i , netreturn_i] = DayStrategy_PL(i, j, o, c, s, TC, method)
%

% -- Step 2: Stock/Future P&L
if ~isnan(c(i-1,j)) && ~isnan(c(i,j)) &&  ~isnan(o(i,j)) && c(i-1,j)~=0 && c(i,j)~=0 && o(i,j)~=0
    switch method
        case {'syc_to2tc'}
            grossreturn_i = s(i-1,j) * (c(i,j)/o(i,j) - 1) ;
            netreturn_i =   s(i-1,j) * ( (1 - s(i,j) * TC(1,j)) * c(i,j) / ((1 + s(i,j) * TC(1,j)) * o(i,j)) - 1) ;  
        case {'syc_yc2tc'}
            grossreturn_i = s(i-1,j) * (c(i,j) / c(i-1,j) - 1) ;  
            netreturn_i =   s(i-1,j) * ( (1 - s(i,j) * TC(1,j)) * c(i,j) / ((1 + s(i,j) * TC(1,j)) * c(i-1,j)) - 1) ;  
        case {'syc_yc2to'}
            grossreturn_i = s(i-1,j) * (o(i,j) / c(i-1,j) - 1) ;  
            netreturn_i =   s(i-1,j) * ( (1 - s(i,j) * TC(1,j)) * o(i,j) / ((1 + s(i,j) * TC(1,j)) * c(i-1,j)) - 1) ;  
        case {'sto_to2tc'}
            grossreturn_i = s(i,j)   * (c(i,j) / o(i,j)-1) ;  
            netreturn_i =   s(i,j)   * ( (1 - s(i,j) * TC(1,j)) * c(i,j) / ((1 + s(i,j) * TC(1,j)) * o(i,j)) - 1) ;            
    end
else
    grossreturn_i = 0;  netreturn_i = 0;
end    
