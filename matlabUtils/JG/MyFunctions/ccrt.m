function [mc, mr, to]=ccrt(x, lag, period)
%__________________________________________________________________________
% Counting Continuation and Reversal Time test (CCRT)
%
% CCRT is a non-parametric method that tests whether the data is 
% sequentially linked.
% If mc > mr, the test generates "trend" as output; otherwise it generates
% "mean reversion" as output.
% INPUT
% x = matrix of price
% lag = the maximum lag to computes price differences. The code compute a
% number "lag" of lagged time series Delta(X(t)) = X(t) - X(t-q)
% period = rolling period over which the test is computed
% OUTPUT
% mc = continuation empirical probability
% mr = reversal empirical probability
% to (trend output) = mc - mr;
%__________________________________________________________________________

% Identify dimensions
[nsteps,ncols]=size(x);
% Prelocate
mc = zeros(size(x));
mr = zeros(size(x));

for j=1:ncols
    % Extract 
    vx = x(:,j);
    % find the first cell to start the counting
    start_date = zeros(1,1);
    for i=1:nsteps
        if ~isnan(vx(i,1)), start_date(1,1)=i;
        break               
        end                                 
    end
    % Build a series of differences X(t) - X(t-q)
    vxlagm = zeros(nsteps, lag);
    for u = 1:lag
        vxlag = Delta(vx,'dif',u);
        vxlagm(:,u) = vxlag(:,1);
    end
    for i=start_date+lag+period:nsteps
        % Slice the matrix vxlagm for period "period"
        vxlagm_period = vxlagm(i - period + 1: i, :);    
        % Initialize Count for period
        mc_period = zeros(1,lag); mr_period = zeros(1,lag);
        % Count
        for u = 1:lag
            for p=lag+1:period
                if sign(vxlagm_period(p,u)) == sign(vxlagm_period(p-lag,u))
                    % trend
                    mc_period(1,u) = mc_period(1,u) + 1;
                else
                    % reversal
                    mr_period(1,u) = mr_period(1,u) + 1;
                end
            end
            % Compute probability for each lag
            mc_period(1,u) = mc_period(1,u) / (period-lag);
            mr_period(1,u) = mr_period(1,u) / (period-lag);
        end
        % Sum probabilities at all lags & assign
        mc(i,j) = sum(mc_period) / lag;
        mr(i,j) = sum(mr_period) / lag;
        
    end
end
% trend output
to = mc - mr;
to = sign(to);