function [y,sy]=FunctionNorminv(x, Direction, method)
%
%__________________________________________________________________________
%
% Compute the normal inverse transform
% x=F^-1(p | mu,sigma), where x is solution of the integral equation below 
% where the desired probability p is supplied:
% p=F(x|mu,sigma)=1/(pi,(2pi)^.5 * Int {e-(t-mu)^2/(2sigma^2)} dt
% 
% This is useful to smooth for outliers

% Direction : +1 or -1
% method: either use mu=0 and sigma=1 (normal distribution,{'mormal','norm'})
%         or mu and sigma of sample 'sample'
% Output:
% y  : is normal inverse transform output
% sy : is normalised y. i.e. y/sum(y)
%__________________________________________________________________________
%
%
x=Direction*x;                      % Direction
rank = tiedrank( x );               % rank
p = rank / ( length(rank) + 1 );    % +1 to avoid Inf for the max point
% normal inverse transform output
switch method
    case {'mormal','norm'}
        y = norminv( p, 0, 1 );
    case 'sample'
        mu=mean(p);
        sigma=std(p);
        y = norminv( p, mu, sigma );
end
%
%  normalised y
sy=y/sum(y);

        