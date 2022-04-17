function[Y] = XYZUSDSpread(X,DirectOrIndirect,method,USDPosition)

%__________________________________________________________________________
% Run the function "CleanFXDirectOrIndirect.m" first
%
% This function computes the difference between an indicator for a FX cross
% and a base currency, i.e., the USD:
%
% INPUTS:
%
% The 'direction' of the database is of a paramount importance.
%      - Direct quote
%      Nb. of USD to buy 1 unit of domestic currency
%      note: Delta(E)/E <(>) 0 ....> Depreciation (Appreciation)
%      - Indirect quote
%      Nb. of domestic currencies to buy 1 USD
%      note: Delta(E)/E <(>) 0 ....> Appreciation (Depreciation)
%      - 'method' is then : 'direct' or
%                           'indirect'
% The variable "DirectOrIndirect" is an indicator function:
%      - if database is Direct   then DirectOrIndirect=1
%      - if database is Indirect then DirectOrIndirect=-1
%
% USPosition is the column number where USD data is.
%
% Two methods:
% case 'difference'   : difference of factors
% case 'ratio'        : ratio of factors
%
% For a databse built in a "Direct" quote, a typical functional form is
% Y = XYZUSDSpread(RateofChange,1,'difference',1)
%__________________________________________________________________________
%
% Pre-locate the matrix & Dimensions
[nsteps,ncols]=size(X);
Y=zeros(size(X));
switch method
        case 'difference'   
        for j=1:ncols
            Y(:,j)=DirectOrIndirect .* (X(:,j)-X(:,USDPosition));
        end
    case 'ratio'
        for j=1:ncols
            if DirectOrIndirect==1
                %Y(:,j)=X(:,j) ./ X(:,USDPosition);
                for i=1:nsteps
                    if ~isnan(X(i,j)) && ~isnan(X(i,USDPosition)) && X(i,USDPosition)~=0 
                        Y(i,j) = X(i,j) / X(i,USDPosition);
                    end
                end
            elseif DirectOrIndirect==-1
                %Y(:,j)=X(:,USDPosition) ./ X(:,j) ;
                for i=1:nsteps
                    if ~isnan(X(i,j)) && ~isnan(X(i,USDPosition)) && X(i,j)~=0 
                        Y(i,j) = X(i,USDPosition) / X(i,j);
                    end
                end                
            end
        end 
end