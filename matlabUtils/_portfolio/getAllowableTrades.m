function [portWts] = getAllowableTrades(targWts, targRiskInMonthlyUnit, rebalTol, dates, holidays) 
% Rebalances a matrix of portfolio weights 
N = size(targWts,2);
indxA = 1:N;
portWts = zeros(size(targWts));

% create holiday structure: true means there is a holiday in period t, for
%   asset n, false otherwise
holMat = false(size(dates,1),size(holidays.holidays,2)); 
dates = floor(dates);
for n = 1:N
    temp = ismember(dates,holidays.holidays{n});
    holMat(:,n) = temp;
end % for n

portWts(1,:) = targWts(1,:);
for t=2:size(targWts,1)
   tempTol = min(targRiskInMonthlyUnit/0.01,1); % Note, if target risk is 1% or higher,  
    %                                then rebalTol is unchanged; for risk  
    %                                less than 1%, the threshold gets reduced 
    %                                proportionately.
   tempR = abs((targWts(t,:)-portWts(t-1,:))) > rebalTol*tempTol; 
   indxR = find(tempR); 
   indxB = setdiff(indxA,indxR); 
   indxH = find(holMat(t,:)); 
   indx0 = find(targWts(t,:)==0); 
   portWts(t,indxR) = targWts(t,indxR); 
   portWts(t,indxB) = portWts(t-1,indxB); % don't trade a position below trading threshold
   portWts(t,indx0) = 0; %#ok<FNDSB> % DO trade a position that is supposed to be closed out, if below the threshold
   portWts(t,indxH) = portWts(t-1,indxH); % do not try to trade on a holiday
end % for
end % fn