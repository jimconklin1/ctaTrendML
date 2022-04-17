function [cmi,cmima] = CandlestickMomentumIndex(o, c, parameters)
%
%--------------------------------------------------------------------------
%
% CMI is the Candlestick Momentum Index

% CMI is an indicator designed to identify true trend strength.
% A high CMI value indicates that short-term trend continuation 
% (follow through) is more likely than short-term trend reversal
% (mean reversion). For e.g., in the case of the CMI computed with the ATR
% method, NASDAQ100 stocks with a value of greater than 1.65 indicate
% a healthy trend environment.
%
%
% -- Input --
%     - parameters(1) is the period for the 1st exponential moving average
%     - parameters(2) is the period for the 1st exponential moving average
%     - parameters(3) is the period for signal (exponential moving average)
% -- Output --
% tsi = the CMI
% tsima = the smoothed CMI (signal)
%--------------------------------------------------------------------------
%

dif         = c - o;
absdif      = abs(dif);
ema_dif     = expmav(dif, parameters(1));
ema_absdif  = expmav(absdif, parameters(1));
ema_dif2    = expmav(ema_dif, parameters(2));
ema_absdif2 = expmav(ema_absdif, parameters(2));  
cmi         = 100 * ema_dif2  ./ ema_absdif2;
cmima       = expmav(cmi,parameters(3));
% -- Clean --
[nsteps,ncols]=size(c);
for j=1:ncols
    if isnan(cmi(1,j)),
        cmi(1,j) = 0;
    end
    if isnan(cmima(1,j)),
        cmima(1,j) = 0;
    end            
end
for j=1:ncols
    % Find first non empty
    %start_date=zeros(1,1);
    %for i=1:nsteps
    %    if ~isnan(y(i,j))
    %        start_date(1,1)=i;
    %    break               
    %    end                                 
    %end    
    for i=2:nsteps
        if isnan(tsi(i,j)) || tsi(i,j) == Inf || tsi(i,j) == -Inf
            cmi(i,j) = cmi(i-1,j); 
        end
        if isnan(tsima(i,j)) || cmima(i,j) == Inf || cmima(i,j) == -Inf
            cmima(i,j) = cmima(i-1,j); 
        end
    end
end
          
     