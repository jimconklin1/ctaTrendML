function[bbi,bbif,bbis] = BubbleIndex(c,h,l,PF,PS)
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
 %x=rand(1000,10);
 %PeriodSmooth=20;
% Identify Dimensions------------------------------------------------------
%
period=13;
k13 = StochasticFunction(c,h,l,period,3,3);
%
period=21;
k21 = StochasticFunction(c,h,l,period,3,3);
%
period=34;
k34 = StochasticFunction(c,h,l,period,3,3);
%
period=55;
k55 = StochasticFunction(c,h,l,period,3,3);
%
bbi=( 13^0.5*k13 + 21^0.5*k21 + 34^0.5*k34 + 55^0.5*k55 ) / (13^0.5 + 21^0.5 + 34^0.5 + 55^0.5);
clear k13 k21 k34 k55
%
bbif=expmav(bbi,PF); bbis=expmav(bbi,PS);