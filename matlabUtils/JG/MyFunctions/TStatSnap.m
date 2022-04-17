function [nwe, tstat] = TStatSnap(t, c, lag)
%
%--------------------------------------------------------------------------
%
% Compute rolling TStat with Newey-West Estimator & Student
%--------------------------------------------------------------------------
%
[nsteps, ncols]=size(c);
xtime = zeros(lag,1); 

for i=1:lag,xtime(i)=i;end;

tstat = zeros(1,ncols);
nwe = zeros(1,ncols);

for j=1:ncols
    y  = log(c(t-lag+1:t,j));
    [b,stats] = robustfit(xtime,y,'ols');
    % Get residuals
    e = stats.resid;
    % Newey-West
    nwse = NeweyWest(e,xtime,-1,1);
    if size(stats.t,1)==2
        tstat(1,j) = stats.t(2,1); 
        nwe(1,j) = b(2,1) / nwse(2,1);
    end
end
