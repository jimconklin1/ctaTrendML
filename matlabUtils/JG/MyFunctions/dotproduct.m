function [z,dotz] = dotproduct(x, method, lookback, lag, corrlookback)

%__________________________________________________________________________
%
% This function computes the dot product between two vectors
%
% INPUT--------------------------------------------------------------------
% x            = matrix of raw data ('n observations x m assets')
% lookback     = lookback period for the price difference
% lag          = time-lag used in the correlation for the 2nd price diff.
% corrlookback = lookback period for correlation
%
%
% OUTPUT-------------------------------------------------------------------
% z         =   z is the cross product.
%__________________________________________________________________________

% -- Identify Dimensions & Prelocate matrix --
[nsteps,ncols] = size(x); 
z = zeros(size(x));

% -- Rebase x --
%for j=1:ncols
    % Find the first cell to start the code
%    for i=1:nsteps
%        if ~isnan(x(i,j)) && x(i,j)>0
%            StartDate=i;
%        break
%        end
%    end
%    pb=x(StartDate,j);
    % Rebase
%    if pb> 0, x(:,j) = x(:,j) ./ repmat(pb,nsteps,1); end
%end

% -- Divergence Indicator --
switch method
    case {'return', 'roc', 'r'}
        d = Delta(x,'roc', lookback);
    case 'price'
        d=log(x);
end
dlag = zeros(size(d));
dlag(lag+1:nsteps,:) = d(1:nsteps-lag,:);

% -- Compute cosine (correlation) --
corddlag = cor2v(d, dlag, 0, 0, corrlookback,'pearson');

% -- Compute cross product --
z = d .* dlag ;
dotz = z .* corddlag;



