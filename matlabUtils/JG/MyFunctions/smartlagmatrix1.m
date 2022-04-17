function y = smartlagmatrix1(xChild, xParent, xChild_StartRow, lag)
%
%__________________________________________________________________________
% PURPOSE:
%     Construct an "y" matrix of lagged values 
% 
% USAGE:
%     y = lagmatrix(xChild,xParent,xChild_StartRow, lag)
% 
% INPUTS:
%     xParent is the Parent matrix from which...
%     xChild is extracted
%     xChild_StartRow: row at which xChild Starts
%     lag is the number of lags(scalar)
% 
% OUTPUTS:
%     y will be (n-p)xp(or p+1 if c=1)(lags)
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%__________________________________________________________________________

% -- check input --
if nargin~=4
    error('lagmatrix: wrong # of input arguments');
end

% -- Dimmensions & Prelocate matrices --
n=length(xChild);
y=zeros(n,lag);

% -- Lag Matrix -- 
for j=1:lag
   y(1:n,j)=xParent(xChild_StartRow - j: xChild_StartRow+(n-1) - j,1);
end;
