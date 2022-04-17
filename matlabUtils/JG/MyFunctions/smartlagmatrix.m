function y = smartlagmatrix(x,p)
%
%__________________________________________________________________________
% PURPOSE:
%     Construct an "y" matrix of lagged values 
% 
% USAGE:
%     y = lagmatrix(x,p)
% 
% INPUTS:
%     x is a matrix
%     p is the number of lags(scalar)
% 
% OUTPUTS:
%     y will be (n-p)xp(or p+1 if c=1)(lags)
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%__________________________________________________________________________

% -- check input --
if nargin~=2, error('lagmatrix: wrong # of input arguments'); end;

% -- Dimmensions & Prelocate matrices --
nsteps = length(x);
y = zeros(nsteps,p);

% -- Lag Matrix -- 
for j=1:p
   y(j:n,j)=x(j+1:n-j,1);
end;
