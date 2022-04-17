function nwse = RollingNeweyWest(e,X,Lag,constant,Lookback)
% PURPOSE: computes Rolling Newey-West adjusted heteroscedastic-serial
%          consistent standard errors
%           use 'NeweyWest' function
%---------------------------------------------------
% where: e = T x 1 vector of model residuals
%        X = T x k matrix of independant variables
%        L = lag length to use (Default: Newey-West(1994) plug-in
%        procedure)

%        constant = 0: no constant to be added;
%                 = 1: constant term to be added (Default = 1)
%
%        nwse = Newey-West standard errors
%---------------------------------------------------

%% Variables
nwse=zeros(length(e),1);
% -- Compute Rollling Logit regression --
    for i = Lookback : nsteps
        e_snap = e(i-Lookback+1:i);
        X_snap = X(i-Lookback+1:i,:);
        % Compute & Assign
        nwse(i) = NeweyWest(e_snap,X_snap,Lag,constant);
    end