function [CovMatrix, StdevMatrix] =ExpCovFunction(X, Period, HalfLife)

%__________________________________________________________________________
%
% This function computes the Exponential Covariance Matrix & 
% Standard Deviation Matrix
% The output is 
% - Exponential Covariance Matrix
%   This is a cube, the depth being the number of data points
%   From time=1 to time=Period-1, the covariance matrix is a zero matrix
% - Exponential Standard Deviation Matrix
%   This is a column vector
%__________________________________________________________________________
%
% Lambda
Lambda = 0.5^(1/HalfLife);
%Lambda=2/(HalfLife+1);
%
% Pre-locate
%
NbSteps = size(X,1);
NbAssets = size(X,2);
CovMatrix = zeros(NbAssets,NbAssets,NbSteps);
StdevMatrix = zeros(NbAssets,NbSteps);
%
% Initialise
CovMatrix(:,:,Period) = cov(X(1:Period,:));
StdevMatrix(:,Period) = sqrt(diag(CovMatrix(:,:,Period)));
% Compute
for i = Period+1:NbSteps
    RecentXX         = repmat(X(i,:),NbAssets,1) .* repmat(X(i,:),NbAssets,1)' ;
    %CovMatrix(:,:,i) = Lambda .* (RecentXX - CovMatrix(:,:,i-1)) + CovMatrix(:,:,i-1);
    CovMatrix(:,:,i) = Lambda .* RecentXX + (1 - Lambda) .* CovMatrix(:,:,i-1);
    %CovMatrix(:,:,i) = (1 - Lambda) .* RecentXX +  Lambda .* CovMatrix(:,:,i-1);
    StdevMatrix(:,i) = sqrt(diag(CovMatrix(:,:,i)));
end
%
% Annualize CovMatrix & StdevMatrix
CovMatrix = CovMatrix .* 12;
StdevMatrix = StdevMatrix .* (12^0.5);