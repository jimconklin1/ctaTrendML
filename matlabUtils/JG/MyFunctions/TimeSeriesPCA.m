%function z = TimeSeriesPCA(x,lookcbackACP, lag, NbEigenVec)
x=c
lag=3
NbEigenVec=3
lookcbackACP=21
%
%__________________________________________________________________________
% PURPOSE:
%     Construct a time-series-based rolling ACP and keep in memory coordinates on
%     the p-th axis
% 
% INPUTS:
%     x is a matrix
%     p is the number of lags(scalar)
% 
% OUTPUTS:
%     a cube with the ACP results at each point of time for each of the
%     Eigenvalues selected
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%__________________________________________________________________________

% -- Dimmensions & Prelocate matrices --
[nsteps,ncols]=size(x);
z=zeros(nsteps,ncols,NbEigenVec);

% Time-based rollin ACP
for j=1:ncols
    for i= lookcbackACP + lag : nsteps
        % -- Extract asset --
        x_fetch=x(i-lookcbackACP+1:i,j);
        % -- Create a lagged matrix --
        y = smartlagmatrix1(x_fetch, x(:,1), i-lookcbackACP+1, lag);
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
        covR=smartcov(R'); % covariance matrix, with observations in rows
        [X, B]=eig(covR);  % X is the factor exposures matrix, B the variances of factor returns
        % -- Assign to Cube --
        for uu=1:NbEigenVec
            z(i,j,uu)=X(length(X),uu);
        end
    end
end