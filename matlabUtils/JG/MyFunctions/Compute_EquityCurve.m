
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

function [ptfec, ptfpl,cumulnetret, stratreturn, netret, ptfecgross, ptfplgross, stratreturngross] = Compute_EquityCurve(c, grossreturn, tcforec)

% -- Dimension --
nsteps = size(c,1);

% -- Prelocation --
    % gross
    cumulgrossret = zeros(size(c));
    ptfecgross = 100*ones(nsteps,1); 
    ptfplgross = 100*ones(nsteps,1);  
    stratreturngross = zeros(nsteps,1);
    % net
    cumulnetret = zeros(size(c));
    ptfec = 100*ones(nsteps,1); 
    ptfpl = 100*ones(nsteps,1);
    stratreturn = zeros(nsteps,1);
    
% -- net return --
netret = grossreturn - tcforec;

% -- Compute --
for i=2:nsteps
    cumulnetret(i,:) = cumulnetret(i-1,:) + netret(i,:);
    cumulgrossret(i,:) = grossreturn(i-1,:) + netret(i,:);
end
for i=2:nsteps
    % gross
    ptfecgross(i) = ptfecgross(i-1) * (1 + sum(grossreturn(i,:)));
    ptfplgross(i) = ptfplgross(i-1) + (100 * sum(grossreturn(i,:)));
    stratreturngross(i) = stratreturngross(i-1) + sum(grossreturn(i,:));    
    % net
    ptfec(i) = ptfec(i-1) * (1 + sum(netret(i,:)));
    ptfpl(i) = ptfpl(i-1) + (100 * sum(netret(i,:)));
    stratreturn(i) = stratreturn(i-1) + sum(netret(i,:));
end