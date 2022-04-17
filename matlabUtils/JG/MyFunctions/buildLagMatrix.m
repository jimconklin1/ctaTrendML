function y = buildLagMatrix(x, lagStruct)
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
%     lagStruct is the number of lags(a row vector)
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
lagNb = size(lagStruct,2);
y = zeros(nsteps,lagNb);

% -- Lag Matrix -- 
for uuu=1:lagNb
   myLag = lagStruct(1,uuu);
   y(myLag+1:nsteps,uuu)=x(1:nsteps-myLag);
end
