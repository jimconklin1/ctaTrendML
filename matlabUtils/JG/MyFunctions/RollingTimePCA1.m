function z = RollingTimePCA1(x, lookback, lag, NbComp)
%
%__________________________________________________________________________
% PURPOSE:
%     Construct a time-based rolling PCA and keep in memory coordinates on
%     the p-th axis
%
% INPUTS:
%     x is a matrix (time-units in row, variable in column)
%     lookback is the rolling window over-which PCA is ocmputed
%     lag is the number of lags(scalar)
% 
% OUTPUTS:
%     a cube with the PCA results at each point of time for each of the
%     Eigenvalues selected
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%z =RollingPCA(c, 100, 0, 10, 'obs_data');
%__________________________________________________________________________

% -- Dimmensions & Prelocate matrices --

[nsteps,ncols]=size(x);
z=zeros(nsteps,NbComp);

% Time-based rolling PCA
for i= lookback + lag : nsteps
    % -- Extract asset --
    x_fetch = x(i-lookback+1:i,:);
    y = smartlagmatrix1(x_fetch, x(:,1), i-lookback+1, lag); % Create a lagged matrix
    [coefs,scores,variances,t2] = pca([x_fetch, y]);
    % check size signalspca
    [nrowssignals, ncolssignals] = size(scores);
    if nrowssignals == lookback && ncolssignals >= NbComp
        z(i,1:NbComp) = scores(size(scores,1), 1:NbComp);
        %z(i,1:NbComp) = scores(size(scores,1), 1:NbComp);
    else
        z(i,1:NbComp) = zeros(1, NbComp);
    end
end
