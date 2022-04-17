function [AssetWeights, Portvol, fval, exitflag] = PortMVO(Sigma, mu, MinMarginalWeight, MaxMarginalWeight)

% NOTE: This function implements a Mean-Variance Optimization.
%
% NOTE: In general, we won't use this function since there is existing package. But rather use it as a function to test the validity.
%
% NOTE: The ultimate goal is to modify this function and achieve risk parity portfolio optimization.

if (nargin < 2 || nargin > 4)
	error('Wrong Number of Arguments');
end

options = optimoptions('fmincon','Algorithm','active-set','Display','off','TolFun',1e-8);

N = size(Sigma, 2);

[AssetWeights, fval, exitflag] = fmincon(@(w) -PortMaxSharpeObj(w, Sigma, mu), ones(N,1)/N, ...
										[], [], ones(1,N), 1, ones(N,1)*MinMarginalWeight, ones(N,1)*MaxMarginalWeight, [], options);
										
										
Portvol = sqrt(AssetWeights' * Sigma * AssetWeights);

fval = -fval;


function objFunction = PortMaxSharpeObj(w, Sigma, mu)

portvar = w' * Sigma * w;

objFunction = w' * mu ./ sqrt(portvar);

