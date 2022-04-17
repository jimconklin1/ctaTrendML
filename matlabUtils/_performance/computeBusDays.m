%
%__________________________________________________________________________
%
% Compute "bus days"
% Bus days being the minimum of days to bring the P&L to 0.
%__________________________________________________________________________
%

function busDays = computeBusDays(x)

nsteps = size(x,1);
cumsumX = cumsum(x,1);     % compute cumsum
sortX = sort(x,'descend'); % sort returns from highest to lowest

% compute bus day (minimum # days to get P&L at 0)
yTemp = cumsumX(nsteps);
idxCounter = 1;

while yTemp >= 0
    yTemp = yTemp - sortX(idxCounter);
    idxCounter = idxCounter + 1;
end
busDays = idxCounter-1;
        
    

