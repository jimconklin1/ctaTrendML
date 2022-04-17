function x = randp(N,M,alpha,b)
% randp generates Pareto random variables.
%
% created: 	Fri Aug  8 1997, (c) Matthew Roughan
% author:  	Matthew Roughan 
% email:   	matthew.roughan@adelaide.edu.au
%
% This function generates Pareto random variables (of type I)
%    see "Statistical Distributions", Evans, Hastings and Peacock, Wiley, 1993
%    or  http://www.maths.adelaide.edu.au/matthew.roughan/probability_distrns/node6.html
%    or  http://en.wikipedia.org/wiki/Pareto_distribution
%
% The Pareto distribution is a classic "heavy-tailed" or "power-law" distribution.
% It has distribution function
%    F(x) = 1 - (b/x)^alpha, for x>=b
% and density
%    f(x) = (alpha/b) * (b/x)^(alpha+1), for x>=b
%
% Its mean is
%    E[X] = b * alpha/(alpha-1), for alpha>1
% but note that the mean is infinite for alpha<=1
%
% Its variance is 
%    Var(X) = b^2 * alpha/[(alpha-1)^2*(alpha-2)], for alpha>1
% but note that the variance is infinite for alpha<=2
%
% Median
%    Med(X) = b * 2^(1/alpha)
%
% INPUTS:
%    (N,M)     size of output matrix of random variables
%    alpha>0   shape parameter of Pareto distribution
%    b>0       location (sometimes called scale) parameter of Pareto distribution
% 
% OUTPUTS
%    x         an (N,M) array of random Pareto distributed numbers
%                 range of x = [b, inf)
% 
% Note the function calls "rand" so if you want to control the seed, use rand('state', seed).
%
% Note that the type II Pareto is just shifted so that x>=0, so to obtain this distribution
% just take
%             x = randp(N,M,alpha,b) - b;
%

if (alpha <= 0)
  error('alpha must be > 0')
end
if (b <= 0)
  error('b must be > 0')
end
if (N<1 | ceil(N) ~= N)
  error('N must be a positive integer')
end
if (M<1 | ceil(M) ~= M)
  error('M must be a positive integer')
end

y = rand(N,M);
x = b*(1-y).^(-1/alpha);

