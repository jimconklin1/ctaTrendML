
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

function [ptfecX, ptfplX,cumulnetretX, stratreturnX, netretX, ptfecgrossX,...
          ptfplgrossX, stratreturngrossX] = IncEquCurve(c, rowIdx, grossreturn, tcforec, ...
                                             ptfec, ptfpl,cumulnetret, stratreturn, netret, ptfecgross, ptfplgross, stratreturngross)

[nsteps,ncols] = size(c);

cumulgrossretX = zeros(1,ncols);
ptfecgrossX = zeros(1,1); 
ptfplgrossX = zeros(1,1);  
stratreturngrossX = zeros(1,1);
% net
cumulnetretX = zeros(1,ncols);
ptfecX = zeros(1,ncols); 
ptfplX = zeros(1,ncols);
stratreturnX = zeros(1,ncols);
   
% -- net return --
netretX(1,:) = grossreturn(rowIdx,:) - tcforec(rowIdx,:);

% -- Compute --
cumulnetretX(1,:) = cumulnetret(rowIdx-1,:) + netret(rowIdx,:);
cumulgrossretX(1,:) = grossreturn(rowIdx-1,:) + netret(rowIdx,:);

% gross
ptfecgrossX = ptfecgross(rowIdx-1) * (1 + sum(grossreturn(rowIdx,:)));
ptfplgrossX = ptfplgross(rowIdx-1) + (100 * sum(grossreturn(rowIdx,:)));
stratreturngrossX = stratreturngross(rowIdx-1) + sum(grossreturn(rowIdx,:));    
% net
ptfecX = ptfec(rowIdx-1) * (1 + sum(netret(rowIdx,:)));
ptfplX = ptfpl(rowIdx-1) + (100 * sum(netret(rowIdx,:)));
stratreturnX = stratreturn(rowIdx-1) + sum(netret(rowIdx,:));
