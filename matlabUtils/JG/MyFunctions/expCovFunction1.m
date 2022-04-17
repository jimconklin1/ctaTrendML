function [covMat, stdevMat] =expCovFunction1(returnForVar, histWindow, halfLife)
%
%__________________________________________________________________________
%
%__________________________________________________________________________

if (nargin < 3)
     error('finance:portopt:missingInputs','You must enter ReturnForVar, HistWindow, halflife');
end
if (size(returnForVar,1) < histWindow +1)
     error('not  enought data points to for hist window');
end

% Dimensions & Parameters
[nsteps,ncols] = size(returnForVar);
lambda = 0.5^(1/halfLife);
covMat = zeros(ncols, ncols, nsteps);
stdevMat = zeros(nsteps, ncols);

% Initialise
covMat(:,:,histWindow) = cov(returnForVar(1:histWindow,:)); % a cube
stdevMat(histWindow,:) = sqrt(diag(covMat(:,:,histWindow))); % a flat matrix

for i = histWindow + 1 : nsteps
    recentXX = repmat(returnForVar(i,:),ncols,1) .* repmat(returnForVar(i,:),ncols,1)' ;
    covMat(:,:,i) = (lambda .* covMat(:,:,i-1)) + ((1-lambda).* recentXX);
    stdevMat(i,:) = sqrt(diag(covMat(:,:,i))); 
end

