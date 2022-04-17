
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

function [ptfec, ptfpl,cumulnetret, stratreturn, netret] = DayStrategy_EquityCurve(c, netreturn)

% -- Dimension --
[nsteps,ncols]=size(c);

% -- Prelocation --
ptfec = 100*ones(nsteps,1); 
ptfpl = 100*ones(nsteps,1);
cumulnetret = zeros(size(c));
stratreturn = zeros(nsteps,1);
netret =  netreturn;
%
% -- Compute --
for i=2:nsteps
    cumulnetret(i,:) = cumulnetret(i-1,:) + netret(i,:);
end
for i=2:nsteps
    ptfec(i) = ptfec(i-1) * (1 + sum(netret(i,:)));
    ptfpl(i) = ptfpl(i-1) + (100 * sum(netret(i,:)));
    stratreturn(i) = stratreturn(i-1) + sum(netret(i,:));
end