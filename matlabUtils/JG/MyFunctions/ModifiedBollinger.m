function[LowBoll,UpBoll,PctB,MA] = ModifiedBollinger(X,MAPeriod,StdPeriod,CovPeriod,LagCov,TroncateVol)

%__________________________________________________________________________
% The function computes the Bollinger Band
% 
% INPUT
% Method ro moving average: - 'exponential'
%                           - 'arithmetic'
% MAPeriod                : Period for moving average
% StdPeriod               : Period for volatility
% NbLow                   : Nb. of Std. Dev. below moving average (<0)
% NbUp                    : Nb. of Std. Dev. above moving average (>0)
%
% OUTPUT
% LowBoll                 : Lower Bollinger
% UpBoll                  : Upper Bollinger
%
%__________________________________________________________________________
%
% -- Prelocate Matrix --
[nsteps,ncols] = size(X); 
LowBoll = zeros(size(X));     UpBoll = zeros(size(X));
%ModLowBoll = zeros(size(X));  ModUpBoll = zeros(size(X));
Dist = zeros(size(X));
%
% -- Moving Average --
MA=expmav(X,MAPeriod); 
%
% -- Volatility --
VolBoll  = VolatilityFunction(X,'simple volatility',StdPeriod,10,TroncateVol);
%
acov = autocov(X, CovPeriod, LagCov);
maacov = expmav(acov,3);

% -- Compute Bollinger --
for j=1:ncols
    start_date=zeros(1,1);
    % Step 1: find the first cell to start the code  
    for i=1:nsteps      
        if ~isnan(X(i,j))
            start_date(1,1)=i;  
            break
        end
    end
    % Step 2: Compute standard deviation
    klong = .9;
    kshort = .9;
    
    for i=MAPeriod+StdPeriod:nsteps
        if acov(i,j) < maacov (i,j)
            if klong < 2
                klong = klong + 0.05;
            else
                klong = 2;
            end
            if klong > -2
                kshort = kshort + 0.05;
            else
                kshort = -2;
            end            
        else
            if klong >=  1
                klong = klong - 0.05;
            else
                klong = 1;
            end
            if kshort <= -  1
                kshort = kshort + 0.05;
            else
                kshort = -1;
            end            
        end
        UpBoll(i,j) = MA(i,j) + klong * VolBoll(i,j);
        LowBoll(i,j) = MA(i,j) + kshort* VolBoll(i,j);
    end
   
end
% Percentage B
PctB=(X-LowBoll) ./ (UpBoll-LowBoll) .* 100;
PctB(find(PctB==Inf)) = 0;
PctB(find(PctB==-Inf)) = 0;