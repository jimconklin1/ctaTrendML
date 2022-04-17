%
%__________________________________________________________________________
%
% Compute Performance of the portoflio
%__________________________________________________________________________
%

function [netretT, cumulnetretT, cumulgrossretT, ptfecgrossT, ptfplgrossT, ...
        stratreturngrossT, ptfecT,  ptfplT, stratreturnT] = timeUnitPtfPerf(rowIndex, netret, grossreturn, tcforec, ...
        cumulnetret, ptfecgross, ptfplgross, stratreturn, stratreturngross, ptfec, ptfpl)


    netretT = grossreturn(rowIndex,:) - tcforec(rowIndex,:);
    % -- Compute Ptf return--
    cumulnetretT = cumulnetret(rowIndex-1,:) + netret(rowIndex,:);
    cumulgrossretT = grossreturn(rowIndex-1,:) + netret(rowIndex,:);
    % gross
    ptfecgrossT = ptfecgross(rowIndex-1) * (1 + sum(grossreturn(rowIndex,:)));
    ptfplgrossT = ptfplgross(rowIndex-1) + (100 * sum(grossreturn(rowIndex,:)));
    stratreturngrossT = stratreturngross(rowIndex-1) + sum(grossreturn(rowIndex,:));    
    % net
    ptfecT = ptfec(rowIndex-1)* (1 + sum(netretT));
    ptfplT = ptfpl(rowIndex-1) + (100 * sum(netretT));
    stratreturnT = stratreturn(rowIndex-1) + sum(netretT);   