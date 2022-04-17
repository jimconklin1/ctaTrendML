
%
%__________________________________________________________________________
%
% Compute Equity Curve
% Inputs:
% c = matrix of close prices
% grossreturn = matrix f gross returns
% tcforec = matrix of transaction costs
%
%__________________________________________________________________________

function [ptfec, ptfpl,cumulnetret, stratreturn, netret] = Pair_EquityCurve(c, grossreturn, tcforec, HedgeRatio, Position_HedgeRatio)

% -- Dimension --
nsteps = size(c,1);

% -- Prelocation --
ptfec = 100*ones(nsteps,1); 
ptfpl = 100*ones(nsteps,1);
cumulnetret = zeros(size(c));
stratreturn = zeros(nsteps,1);
netret = grossreturn - tcforec;
%
% -- Compute --
for i=2:nsteps
    cumulnetret(i,:) = cumulnetret(i-1,:) + netret(i,:);
end
for i=2:nsteps
    if Position_HedgeRatio == 1
        ptfec(i) = ptfec(i-1) * (1 +    HedgeRatio(i) * netret(i,1) + netret(i,2) );
        ptfpl(i) = ptfpl(i-1) + (100 * (HedgeRatio(i) * netret(i,1) + netret(i,2) ));
        stratreturn(i) = stratreturn(i-1) + HedgeRatio(i) * netret(i,1) + netret(i,2);
    elseif Position_HedgeRatio == 2
        ptfec(i) = ptfec(i-1) * (1 + netret(i,1) +        HedgeRatio(i) * netret(i,2) );
        ptfpl(i) = ptfpl(i-1) + (100 * (netret(i,1) +     HedgeRatio(i) * netret(i,2) ));
        stratreturn(i) = stratreturn(i-1) + netret(i,1) + HedgeRatio(i) * netret(i,2);
    end
end