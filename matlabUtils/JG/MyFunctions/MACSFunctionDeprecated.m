function[macs,mamacs,Increment] = MACSFunctionDeprecated(x,method,MinLookbackPeriod,MaxLookbackPeriod,SlowToFastFactor,PeriodSmooth)
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
[nsteps,ncols]=size(x);
macs=zeros(size(x));
%
% Compute increment
Increment=1;%100/(MaxLookbackPeriod-MinLookbackPeriod+1);
%
for j=1:ncols
    x_macs_u=zeros(nsteps,MaxLookbackPeriod);
    for u=MinLookbackPeriod:MaxLookbackPeriod 
        switch method
            case 'exponential'
            % Moving average u
            ma_u=expmav(x(:,j),u);
            % Moving average StFu
            ma_StFu=expmav(x(:,j),SlowToFastFactor*u);
            case 'exp'
            % Moving average u
            ma_u=expmav(x(:,j),u);
            % Moving average StFu
            ma_StFu=expmav(x(:,j),SlowToFastFactor*u);            
            case 'arithmetic'
            % Moving average u
            ma_u=amav(x(:,j),u);
            % Moving average StFu
            ma_StFu=amav(x(:,j),SlowToFastFactor*u);
            case 'arith'
            % Moving average u
            ma_u=amav(x(:,j),u);
            % Moving average StFu
            ma_StFu=amav(x(:,j),SlowToFastFactor*u);            
        end
        % Difference between ma_u and ma_StFu
        Diff_ma_u=ma_u-ma_StFu;
        clear ma_u ma_StFu
        % Identify difference (normalise @ 5 for percentage)
        Diff_ma_u(find(Diff_ma_u <= 0)) = -Increment;
        Diff_ma_u(find(Diff_ma_u >  0)) = Increment;  
        % Assign
        x_macs_u(:,u)=Diff_ma_u;
        % Clear
        clear Diff_ma_u
    end
    for i=1:nsteps
       macs(i,j)= sum(x_macs_u(i,:));
    end
end
% Smooth Probability
mamacs=expmav(macs,PeriodSmooth);