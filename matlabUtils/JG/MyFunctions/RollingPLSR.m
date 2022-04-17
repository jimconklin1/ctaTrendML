function [betamat, msemat, scoremat] = RollingPLSR(x, y , ncomp, LagStructure, Lookback_Period)

%__________________________________________________________________________
%
% Rolling Partial least-squares regression
% INPUT
% Y = time series of close on which we compute the change
% X = set of explaining variables
% note: add a column of one if needed
% LagDiff = the lag for the momentum.
%           note: one want to forecast the direction of the move, for e.g.
%           a weekly move on a daily time series, LagDiff = 5;
% LagStructure = the lag-structure for the factors
%           note: for instance if you think that there is a lag of 20-day
%           between the explaining variables and the direction of the
%           momentun, you write LagStructure = 20;
% Lookback_Period = Period over which you estimate the Rolling Logistic
% Regression
%
%
% Joel Guglietta - April 2015
%
%__________________________________________________________________________

% -- Dimension & Prelocate amtrix --
[nsteps, ncols] = size(y);
% xlmat = zeros(size(y));
% ylmat = zeros(size(y));
% xsmat = zeros(size(y));
% ysmat = zeros(size(y));
betamat = zeros(size(y));
msemat = zeros(size(y));
scoremat = zeros(size(y));

% -- Compute Rollling Logit regression --
for j=1:ncols
    for i = Lookback_Period + LagStructure : nsteps
        x_snap = x(i-Lookback_Period+1-LagStructure:i-LagStructure,:);
        y_snap = y(i-Lookback_Period+1:i,j);
        [xl,yl,xs,ys,beta,pctvar,mse] = plsregress(x_snap, y_snap, ncomp);
        clear xl yl xs ys pctvar
        % Assign
        betamat(i,j) = beta(1,1);
        msemat(i,j) = mse(2,1);
        junk = y_snap-[ones(length(y_snap),1),x_snap]*beta;
        scoremat(i,j)=junk(length(junk),1);
    end
end