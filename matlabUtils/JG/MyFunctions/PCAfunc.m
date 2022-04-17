function [signalspca, pc, eval, veval]=PCAfunc(x,method)

%__________________________________________________________________________
%
% pca1: Performs Principal Componant Analysis using covariance matrix
%
% INPUTS
% data: table of data on which to perform the PCA
% method: looks at the 'orientation' of the table
%       - 'obs_data': [rows    = observations (trials/days/time)] x ...
%                     [columns = data/dimensions/nb.OfMeasurementTypes]
%       - 'data_obs': [rows    = data/dimensions/nb.OfMeasurementTypes] x ...
%                     [columns = observations (trials/days/time)]
% note :
%
% 1. Performing a PCA, goes down to find a matrix P where Y = PX such that
%    SY = (1/(n-1)) * YY' is diagonalized.
% The matrix X (here, 'data') is an 'm x n' matrix, where 
%   - 'm' is the number of measurement types (for istance number of stocks) 
%   - 'n' is the number of trials (nb. of observations, nb. of days).
% This explains why the code TRANSPOSES the original data matrix if the
% table is oriented as follows: N observations (nsteps) * M assets (ncols)
%
% 2. SY = (1/(n-1)) * YY' 
%       = (1/(n-1)) * P(XX')P'
%    let's write  A = XX', A is symetric (basic algebra rule)
%    A symetric matrix is diagonalized by an orthogonal matrix of its
%    eigenvectors
%    A = EDE', with D a diagonal matrix, E matrix of eigenvectors of A
%    arranged as columns
%
% 3. The PCA's trick: Select P to be a matrix where each row p(i) is an
%  eigenvector of XX'. Therefore P = E'.
%  As E is orthogonal, P is orthogonal and Inv(P) = P' (the tranpose of an
%  orthogonal matrix equals its inverse)
%  Hence S(Y) = (1/(n-1)) D
%  This choice of P diagonalized SY
%
% 4. The principal components of X are the eigenvectors of XX', i.e. the
% ROWS of P
% The ith diagonal value of SY is the variance of X along pi.
%
% note: the code uses E.P. Chan 'smartmean' function and 'smartcov' 
%       function with N (nsteps) observations in rows and M (ncols) 
%       assets in columns, reason why the code RE-TRANSPOSE the centered 
%       data matrix.
%
% OUTPUT
% pc :        each column is a principal component
% veval:      vector colomn (ncols x 1) matrix of variances
% signalspca: projection on the principal componant axis
% IMPORTANT NOTE: note that the principal component
%
% Joel Guglietta
% 06/06/2012
%__________________________________________________________________________

% -- Dimensions --
[nsteps,ncols] = size(x);

% -- Transpose or Do not Transpose data table (depends upon orientation) --
switch method
    case {'obs_data' , 'od' , 'time_measurement' , 'time_factors'}
    tx = x';    % Transpose the matrix of data
    case {'data_obs' , 'do' , 'measurement_time' , 'factors_time'}
    tx = x;     % DO NOT transpose the matrix of data
end

% -- Substract off the mean for each dimension --
hasData = find(all(isfinite(tx), 2)); % avoid any stocks with missing returns
tx = tx(hasData, :);
mn = smartmean(tx,2);
switch method
    case {'obs_data' , 'od' , 'time_measurement' , 'time_factors'}
        ctdx = tx - repmat(mn, [1, nsteps]);
    case {'data_obs' , 'do' , 'measurement_time' , 'factors_time'}
        ctdx = tx - repmat(mn, [1, ncols]);
end

% -- Compute the convariance matrix --
covx = smartcov(ctdx'); % re-transposition is need for this function

% -- Find the eigenvectors and eigenvalues --
[pc, eval] = eig(covx); 

% -- Extract diagonal of eigenvalues matrix as vector --
veval = diag(eval);

% -- Sort the variances in decreasing order --
[junk, rindices] = sort(-1*veval);
veval = veval(rindices);    
pc = pc(:,rindices);  
clear junk

% -- Project the original data set --
signalspca = pc' * tx;
switch method
    case {'obs_data' , 'od' , 'time_measurement' , 'time_factors'}
    	signalspca = signalspca';
    case {'data_obs' , 'do' , 'measurement_time' , 'factors_time'}
    	signalspca = signalspca;
end
