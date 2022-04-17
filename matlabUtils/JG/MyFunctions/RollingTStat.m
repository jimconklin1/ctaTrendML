function [nwe, tstat] = RollingTStat(c, lag)
%
%--------------------------------------------------------------------------
%
% Compute rolling TStat with Newey-West Estimator & Student
%--------------------------------------------------------------------------
%
[nsteps, ncols]=size(c);
xtime = zeros(lag,1); 

for i=1:lag,xtime(i)=i;end;

tstat = zeros(nsteps,ncols);
nwe = zeros(nsteps,ncols);
for j=1:ncols
    for i=lag+1:nsteps
        y  = log(c(i-lag+1:i,j));
        [b,stats] = robustfit(xtime,y,'ols');
        % Get residuals
        e = stats.resid;
        % Newey-West
        nwse = NeweyWest(e,xtime,-1,1);
        if size(stats.t,1)==2
            tstat(i,j) = stats.t(2,1); 
            nwe(i,j) = b(2,1) / nwse(2,1);
        else
            tstat(i,j) = tstat(i-1,j);
            nwe(i,j) = nwe(i-1,j);
        end
    end
end
