function[matk,matd] = StochasticConfluenceFunction(c,h,l,MinLookbackPeriod,MaxLookbackPeriod,psmooth,method)
%
%__________________________________________________________________________
%
% This function computes the Moving Average Confluence indicator.
% INPUT....................................................................
% X                   = price
% 'method'            = 'arithmetic' or 'exponential' moving averages
%                       element in the data base.
% MinLookbackPeriod   = Minimum period for moving average.
% MaxLookbackPeriod   = Maximum period for moving average.
% SlowToFastFactor    = Constant to multiply the slow MA (2,3,4 are best).
% PeriodSmooth        = period in order to smooth macs.
% OUTPUT...................................................................
% macs = moving average confluence.
% mamacs = smoothed moving average confluence.
% Increment
%__________________________________________________________________________
%
% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(c);
%
switch method
    case 'normal'
        matk=zeros(size(c));
        matd=zeros(size(c));
        for j=1:ncols
            x_k_u=zeros(nsteps,MaxLookbackPeriod);
            x_d_u=zeros(nsteps,MaxLookbackPeriod);
            for u=MinLookbackPeriod:MaxLookbackPeriod 
                %
                [k_u,d_u,sd_u] = StochasticFunction(c,h,l,u,3,3);
                % Assign
                x_k_u(:,u)=k_u;
                x_d_u(:,u)=d_u;
                % Clear
                %clear x_k_u
            end
            for i=1:nsteps
               matk(i,j)= sum(x_k_u(i,:))/(MaxLookbackPeriod-MinLookbackPeriod+1);
               matd(i,j)= sum(x_d_u(i,:))/(MaxLookbackPeriod-MinLookbackPeriod+1);
            end
        end
    case {'fibo', 'fibonacci'}
        k13 = StochasticFunction(c,h,l,13,3,3);
        k21 = StochasticFunction(c,h,l,21,3,3);
        k34 = StochasticFunction(c,h,l,34,3,3);
        matk = (13^0.5*k13 + 21^0.5*k21 + 34^0.5*k34) / (13^0.5+21^0.5+34^0.5);
        matd=expmav(matk , psmooth);
        clear k13 k21 k34
end