function rrw = RiskReward3(x,emaf,emas,period)
%
%__________________________________________________________________________
%
% This function computes the risk reward index.
% INPUT....................................................................
% X                   = price
% 'method'            = 'arithmetic' or 'exponential' moving averages
%                       element in the data base.
% MinLookbackPeriod   = Minimum period for moving average.
% MaxLookbackPeriod   = Maximum period for moving average.
% SlowToFastFactor    = Constant to multiply the slow MA (2,3,4 are best).
% pf                  = fast period in order to smooth rrw.
% ps                  = slow period in order to smooth rrw.
% OUTPUT...................................................................
% rrw =  risk reward index.
% rrwf = smoothed risk reward index.
% rrws = smoothed risk reward index.
%__________________________________________________________________________
%
% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(x);
% -- 8day volatility --
 
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
rrw = (emaf - emas) ./ volperiod;
clear volperiod

% -- Clean metrics --
rrw(1,:)=zeros(1,ncols);
for j=1:ncols
    for i=1:nsteps
        if isnan(rrw(i,j))
            rrw(i,j)=0;
        end
    end    
    for i=2:nsteps
        if rrw(i,j)==Inf || rrw(i,j)==-Inf
            rrw(i,j)=0;
        end
    end  
end

