%function z = attractorReconstruction(x,lookcbackPCA, LagStructure, NbEigenVec, methodCenter)
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
%     method: center or do not center
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
zCoeff = zeros(nsteps,ncols,NbEigenVec);
zScore = zeros(nsteps,ncols,NbEigenVec);
att = zeros(size(x));

% -- Dimension of lag structure --
ncolslag = size(LagStructure,2);
maxlag = max(LagStructure);

methodChosen = 'new';

if strcmp(methodChosen,'old')

    % Time-based rolling PCA
    for j=1:ncols
        for i= lookcbackPCA + maxlag : nsteps
            % -- Extract asset --
            xSnap = x(i-lookcbackPCA+1:i,j);
            % -- Create a lagged matrix --
            xSnapLagged = zeros(lookcbackPCA, ncolslag);
            for uu = 1:ncolslag
                lagSnap = LagStructure(1,uu);
                xSnapLagged(:,uu) = x(i-lookcbackPCA+1-lagSnap:i-lagSnap,j);
            end
            xSnapFinal= [xSnap, xSnapLagged];
            %[coeff,score] = princomp(xSnapFinal);
            % -- Transpose & Clean Lagged Matrix --
            R = xSnapFinal';                              % columns of R are the different observations
            hasData=find(all(isfinite(R), 2));            % avoid any instrument with missing returns
            R = R(hasData, :);
            % -- Center or Do Not Center Transposed-Cleaned Lagged Matrix --
            if strcmp(methodCenter, 'center')
                avgR=smartmean(R, 2);
                R=R-repmat(avgR, [1 size(R, 2)]); % subtract mean from values            
            elseif  strcmp(methodCenter, 'no center') || strcmp(methodCenter, 'do not center') 
                R = R;
            end
            % -- Extract Eigenvectors on Covar Matrix of Lagged Matrix --
            covR = smartCov(R'); % covariance matrix, with observations in rows
            [X, B]=eig(covR);    % X is the factor exposures matrix, B the variances of factor returns
            % -- Assign to Cube --
            for uu=1:NbEigenVec
                z(i,j,uu)=X(length(X),uu);
            end
        end
    end

elseif strcmp(methodChosen,'new')

    for j=1:ncols
        for i= lookcbackPCA + maxlag : nsteps
            % -- Extract asset --
            xSnap = x(i-lookcbackPCA+1:i,j);
            % -- Create a lagged matrix --
            xSnapLagged = zeros(lookcbackPCA, ncolslag);
            for uu = 1:ncolslag
                lagSnap = LagStructure(1,uu);
                xSnapLagged(:,uu) = x(i-lookcbackPCA+1-lagSnap:i-lagSnap,j);
            end
            xSnapFinal = [xSnap, xSnapLagged];
            [coeff,score] = pca(xSnapFinal);
            % -- Assign to Cube --
            for uu=1:NbEigenVec
                zCoeff(i,j,uu)=coeff(length(coeff),uu); % Principal component
                zScore(i,j,uu)=score(length(coeff),uu);
            end
            % -- Center or Do Not Center Transposed-Cleaned Lagged Matrix --
            if strcmp(methodCenter, 'center')
                avgxSnapFinal = smartmean(xSnapFinal, 2);
                xSnapFinal = xSnapFinal-repmat(avgR, [1 size(xSnapFinal, 2)]); % subtract mean from values            
            elseif  strcmp(methodCenter, 'no center') || strcmp(methodCenter, 'do not center') 
                xSnapFinal = xSnapFinal;
            end 
            % Reconstruct attractor
            princComp = coeff(:,1)';
            princComp(princComp<=0) = NaN;
            minPc = min(princComp);
            princComp(isnan(princComp))=minPc;
            att(i,j) = princComp * xSnapFinal(end,:)';
        end
    end
    
end