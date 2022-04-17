function dti = DirectionalTrendIndex(h, l,parameters)
%
%--------------------------------------------------------------------------
%
% DTI is the Directional Trend Index

% DTI is an indicator designed to identify the direction of the  trend.
% The DTI provides an excellent susbstitute for price. It presents
% characteristics that closely identify it with the True Strength Index.
% A positive price trend is uniquely identified by a rise occuring in the
% positive region of the DTI momentum indicator.
% A negative price trend is uniquely identified by a decline occuring in
% the negative region of the momentum indicator.
% All other regions of the momentum indicator are potentially erroneous.
%
% "Momentum, Direction and Divergence", William Blau,
% Willey, p. 60. Set up DTI(HLM,25,13)= ema(ema(r1d,25),13);
% and ema_tsi=expmav(tsi,70;
%
% -- Input --
% Highs & Lows
% period_ma: the period for the smoothing device
% -- Output --
% dti = the TSI
%
% -- Interesting Set up --
% W. Blau suggests different set-ups
% dti = DirectionalTrendIndex(h, l,[60,32]) with 5-bar signals
% dti = DirectionalTrendIndex(h, l,[25,13]) with 5-bar signals
% dti = DirectionalTrendIndex(h, l,[20,20]) with 5-bar signals
% dti = DirectionalTrendIndex(h, l,[32,32]) with 5-bar signals
% dti = DirectionalTrendIndex(h, l,[32,1]) with 32-bar signals
% dti = DirectionalTrendIndex(h, l,[25,1]) with 25-bar signals
% %--------------------------------------------------------------------------
%
% -- Dimensions & Prelocate --
[nsteps,ncols]=size(h);
hmu = zeros(size(h)); % High Momentum Up
lmd = zeros(size(h)); % Low Momentum Down
%
% --Compute HLM --
for j=1:ncols
    for i=2:nsteps
        if h(i,j) > h(i-1,j)
            hmu(i,j) = h(i,j) - h(i-1,j);
        else
            hmu(i,j) = 0;
        end
    end
    for i=2:nsteps
        if l(i,j) < l(i-1,j)
            lmd(i,j) = h(i,j) - l(i-1,j);
        else
            lmd(i,j) = 0;
        end
    end
end
hlm = hmu - lmd; % High-Low Momentum
hlm_ma = expmav(hlm, parameters(1));
hlm_ma2 = expmav(hlm_ma, parameters(2));
hlm_abs_ma = expmav(abs(hlm), parameters(1));
hlm_abs_ma2 = expmav(hlm_abs_ma, parameters(2));
clear hmu lmd hlm_ma hlm_abs_ma
%
% -- Directional Trend Index --
dti = 100 * hlm_ma2 ./ hlm_abs_ma2;
clear hlm_ma2 hlm_abs_ma2
%
% -- Clean --
for j=1:ncols
    if isnan(dti(1,j)), dti(1,j) = 0; end
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
        if isnan(dti(i,j)) || dti(i,j) == Inf || dti(i,j) == -Inf,
            dti(i,j) = dti(i-1,j);
        end
    end
end      
     