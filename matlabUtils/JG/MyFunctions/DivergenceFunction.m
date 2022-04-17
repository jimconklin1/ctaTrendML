function[spreadc,nspreadc,sspreadc] = DivergenceFunction(X, period_ma, period_vol, period_smooth)
%__________________________________________________________________________
%
% This function computes the divergence indicator as epxlainted
% "Quantitative Trading Strategies", Kestner, Mc Graw Hill
% Output
%
% Input
% - period_ma
% - period_vol
%__________________________________________________________________________

[ncols,nsteps]=size(X);

% Assign varibale
c=X;

% Compute mnoving average
mac=amav(c,period_ma);

% Compute volatility of 1 day change
c1dd = RateofChange(c,'difference',1);
% Compute Volatility
std_c1dd = VolatilityFunction(c1dd,'std',period_vol,3,10e10);
for j=1:ncols
    for i=2:nsteps
        if std_c1dd(i)==0 || std_c1dd(i)==Inf || std_c1dd(i)==-Inf || isnan(std_c1dd(i))
            std_c1dd(i)=std_c1dd(i-1);
        end
    end
end

% Compute Spread
spreadc=c-mac;

% Normalised spread
nspreadc=spreadc ./ std_c1dd;

% Clean Normalised Spread
for j=1:ncols  
    for i=2:nsteps
        if nspreadc(i)==Inf || nspreadc(i)==-Inf || isnan(std_c1dd(i))
            nspreadc(i)=0;
        end
    end    
    for i=2:nsteps
        if nspreadc(i)==0 || nspreadc(i)==Inf || nspreadc(i)==-Inf || isnan(nspreadc(i))
            nspreadc(i)=nspreadc(i-1);
        end
    end 
end
    
% Smoothed Normalised Spread
sspreadc=amav(nspreadc,period_smooth);
