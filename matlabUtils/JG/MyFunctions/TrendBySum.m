%__________________________________________________________________________
% Sum of Signs - Trend Following Indicator
%
% This macro sums of sign of the differencesof the last point of a sequence
% of length "lookback" with respect to the lookback-1 previous point
% 
%__________________________________________________________________________
%
function sx = TrendBySum(x, lookback)
%__________________________________________________________________________


% -- Dimension s7 Prelocate matrices --
[nsteps,ncols] = size(x);
sx = zeros(size(x));
for j=1 : ncols
    for i=lookback+1:nsteps
        % extract column vector
        vx = x(i-lookback+1:i,j);
        % compute sum of signs
        sct=0; 
        for u = 1:lookback-1
            sct = sct + sign(vx(lookback) - vx(u)); 
        end
        sx(i,j) = sct;
    end
end