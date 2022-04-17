function z = TimeRollingPCA(x,lookcbackPCA, LagStructure, NbEigenVec)
%
%__________________________________________________________________________
% PURPOSE:
%     Construct a time-based rolling PCA and keep in memory coordinates on
%     the p-th axis
% 
% INPUTS:
%     lag is a row vector
%     x is a matrix
%     p is the number of lags(scalar)
% 
% OUTPUTS:
%     a cube with the PCA results at each point of time for each of the
%     Eigenvalues selected
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%__________________________________________________________________________


% -- Dimmensions & Prelocate matrices --
[nsteps,ncols]=size(x);
z=zeros(nsteps,ncols,NbEigenVec);

% -- Dimension of lag structure --
ncolslag = size(LagStructure,2);
maxlag = max(LagStructure);


% Time-based rolling PCA
for j=1:ncols
    for i= lookcbackPCA + maxlag : nsteps
        % -- Extract asset --
        x_fetch = x(i-lookcbackPCA-maxlag+1:i,j);
        % -- Create a lagged matrix --
        y = zeros(lookcbackPCA+maxlag, 1);
        for uu = 1:ncolslag
            y = [y , buildLagMatrix(x_fetch, LagStructure(1,uu))];
        end
        y(:,1) = [];
        % -- Transpose & Clean Lagged Matrix --
        R=y';                 % columns of R are the different observations
        hasData=find(all(isfinite(R), 2)); % avoid any stocks with missing returns
        R=R(hasData, :);
        % -- Center or Do Not Center Transposed-Cleaned Lagged Matrix --
        CenterOption=0;
        if  CenterOption==1
            avgR=smartmean(R, 2);
            R=R-repmat(avgR, [1 size(R, 2)]); % subtract mean from values
        end
        % -- Extract Eigenvectors on Covar Matrix of Lagged Matrix --
        covR=smartCov(R'); % covariance matrix, with observations in rows
        [X, B]=eig(covR);  % X is the factor exposures matrix, B the variances of factor returns
        % -- Assign to Cube --
        for uu=1:NbEigenVec
            z(i,j,uu)=X(length(X),uu);
        end
    end
end