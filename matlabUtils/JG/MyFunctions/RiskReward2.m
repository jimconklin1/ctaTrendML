function[rrw,rrwf,rrws] = RiskReward2(x,pf,ps)
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
period=8;
maperiod=expmav(x,period);  
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
cr8=(x-maperiod)./volperiod;
% -- 13day volatility --
period=13;
maperiod=expmav(x,period);  
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
cr13=(x-maperiod)./volperiod;
clear maperiod volperiod
% -- 21day volatility --
period=21;
maperiod=expmav(x,period);  
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
cr21=(x-maperiod)./volperiod;
clear maperiod volperiod
% -- 34day volatility --
period=34;
maperiod=expmav(x,period);  
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
cr34=(x-maperiod)./volperiod;
clear maperiod volperiod
% -- 55day volatility --
period=55;
maperiod=expmav(x,period);  
volperiod = VolatilityFunction(x,'std',period,3,10e10); 
cr55=(x-maperiod)./volperiod;
clear maperiod volperiod

% -- Average nb. of Std. away from the mean --
rrw = (cr8 + cr13 + cr21 + cr34 + cr55) / 5;
clear cr8 cr13 cr21 cr34 cr55 
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
    %for i=2:nsteps
    %    if rrw(i,j)==0
    %        rrw(i,j)=rrw(i-1,j);
    %    end
    %end    
end
rrwf=expmav(rrw,pf);rrws=expmav(rrw,ps);
