function z = crossproduct(x, lookback1, lookback2, lag1, lag2, corrlookback)

%__________________________________________________________________________
%
% This function computes the cross product between two vectors
%
% INPUT--------------------------------------------------------------------
% x            = matrix of raw data ('n observations x m assets')
% lookback1    = lookback period for the first price difference
% lookback2    = lookback period for the second price difference
% lag1         = time-lag used in the correlation for the 1st price diff.
% lag2         = time-lag used in the correlation for the 2nd price diff.
% corrlookback = lookback period for correlation
%
% note 1: the functions makes use of the 'Delta' and the 'cor2v' functions
% note 2: the cosine between two vectors 'a' and 'b' is the correlation
%         cos<a,b> = corr(a,b)
%         and (cos<a,b>)^2 + (sin<a,b>)^2 = 1, 
%         therefore sin(a) = sqrt(1-(corr(a,b))^2) * sign<a,b>
%
% OUTPUT-------------------------------------------------------------------
% z         =   z is the cross product.
% Typical form: z = ZScore(x,'arithmetic',20,[-3,3],1)
%__________________________________________________________________________

% -- Identify Dimensions & Prelocate matrix --
[nsteps,ncols] = size(x); 
z = zeros(size(x));

% -- Rebase x --
for j=1:ncols
    % Find the first cell to start the code
    for i=1:nsteps
        if ~isnan(x(i,j)) && x(i,j)>0
            StartDate=i;
        break
        end
    end
    pb=x(StartDate,j);
    % Rebase
    if pb> 0, x(:,j) = x(:,j) ./ repmat(pb,nsteps,1); end
end

% -- Divergence Indicator --
dl1 = Delta(x,'roc', lookback1);
dl2 = Delta(x,'roc', lookback2);
dsum = lookback2 * dl1 + lookback1 * dl2;

% -- Compute sinus --
cord = cor2v(dl1, dl2, lag1, lag2, corrlookback,'pearson');
sind = sign(cord) .* sqrt(ones(size(cord)) - cord .* cord); 
clear cord

% -- Compute cross product --
z = dsum .* sind;
z(find(all(isnan(z)))) = 0;
z(find(all(~isfinite(z)))) = 0;


