function [portWts] = getThreshRebal(targWts, targRiskInMonthlyUnit, rebalTol, dates, holidays) 
% Rebalances a matrix of portfolio weights 
indxA = 1:size(targWts,2);
portWts = zeros(size(targWts));

% create holiday structure:
portWts(1,:) = targWts(1,:);
for t=2:size(targWts,1)
   tempTol = min(targRiskInMonthlyUnit/0.01,1); % Note, if target risk is 1% or higher,  
    %                                then rebalTol is unchanged; for risk  
    %                                less than 1%, the threshold gets reduced 
    %                                proportionately.
   tempR = abs((targWts(t,:)-portWts(t-1,:))) > rebalTol*tempTol; 
   indxR = find(tempR); 
   indxB = setdiff(indxA,indxR); 
   indx0 = find(targWts(t,:)==0); 
   portWts(t,indxR) = targWts(t,indxR); 
   portWts(t,indxB) = portWts(t-1,indxB);
   portWts(t,indx0) = 0;
end % for
end % fn