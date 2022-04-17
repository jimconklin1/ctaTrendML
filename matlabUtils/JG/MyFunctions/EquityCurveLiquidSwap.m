%
%__________________________________________________________________________
%
% Compute Equity Curve on daily basis
%
%__________________________________________________________________________

function [netret_t, cumulnetret_t, stratreturn_t, ptfpl_t, ptfec_t]  = ...
         EquityCurveLiquidSwap(c, i, grossreturn, tcforec, cumulnetret, stratreturn, ptfec, ptfpl, mgtFees )

% -- Prelocate --
netret_t = zeros(1,size(c,2));
cumulnetret_t = zeros(1,size(c,2));
                        
% -- Instrument net return --
netret_t(1,:) = grossreturn(i,:) - tcforec(i,:) - mgtFees(i,:);

% -- Cumulated net return --
cumulnetret_t(1,:) = cumulnetret(i-1,:) + netret_t(1,:) ;

% -- Strategy's return (summation) --
stratreturn_t = stratreturn(i-1) + sum(netret_t(1,:));

% -- Strategy's Equity Curve (arithmetic) --
ptfpl_t = ptfpl(i-1) + (100 * sum(netret_t(1,:)));

% -- Strategy's Equity Curve (geometric) --
ptfec_t = ptfec(i-1) * (1 + sum(netret_t(1,:)));

