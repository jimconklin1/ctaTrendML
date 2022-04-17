%
%__________________________________________________________________________
%
% This function is used in the Maximium Diversified Portfolio Script
%
% lmom  function
%
% It gwets as inputs:
% - vector of returns X 
% - number of L-moments(nL)
%
% we want to compute and gives as output the nL L-moments. 
% The function uses the function: LegendShiftPoly() given hereafter
%
%__________________________________________________________________________
%
%
function [L] = lmom(X,nL)

[nrows,ncols] = size(X);

if ncols ==1, X = X'; end

n = length(X);
X = sort(X);
b = zeros(1,nL-1);
l = zeros(1,nL-1);
b0 = mean(X);

for r =1:nL-1
    Num = prod(repmat(r+1:n,r,1) - repmat([1:r]',1,n-r),1);
    Den = prod(repmat(n,1,r) - [1:r]);
    b(r) = 1/n * sum(Num/Den .* X(r+1:n) );
end

tB = [b0, b]';
B = tB(length(tB) : -1: 1);

for i = 1:nL-1
    
    Spc = zeros(length(B) - (i+1), 1);
    Coeff = [Spc ; LegendreShiftPoly(i)];
    l(i) = sum((Coeff .* B),1);
    
    L = [b0, l];
    
end