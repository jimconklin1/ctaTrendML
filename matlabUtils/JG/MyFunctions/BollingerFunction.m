function[LowBoll,UpBoll,PctB,MA] = BollingerFunction(X,method,MAPeriod,StdPeriod,TroncateVol,NbLow,NbUp)

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
switch method
    case {'exponential', 'ema', 'exp', 'e'}
        MA=expmav(X,MAPeriod);            
    case { 'arithmetic','ama', 'arithma', 'a'}
        MA=arithmav(X,MAPeriod);           
end
%
% -- Volatility --
VolBoll  = VolatilityFunction(X,'simple volatility',StdPeriod,10,TroncateVol);
%
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
    LowBoll(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j) = MA(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j) +  ...
        NbLow *VolBoll(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j) ;
    
    UpBoll(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j)  = MA(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j) +  ...
        NbUp*VolBoll(start_date(1,1)+MAPeriod+StdPeriod:nsteps,j);     
end
% Percentage B
PctB=(X-LowBoll) ./ (UpBoll-LowBoll) .* 100;
PctB(find(PctB==Inf)) = 0;
PctB(find(PctB==-Inf)) = 0;