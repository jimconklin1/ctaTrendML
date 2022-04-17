function y = divergence(x,fastperiod,slowperiod)

%__________________________________________________________________________
%
% This function computes the divergence index
%
% INPUT--------------------------------------------------------------------
% x         =   matrix of raw data
% period    =   fast period
%               slow period
%
% OUTPUT-------------------------------------------------------------------
% z         =   z is the z-score.
% Typical form: z = ZScore(x,'arithmetic',20,[-3,3],1)
%__________________________________________________________________________

% Identify Dimensions & Prelocate matrix
[nsteps,ncols] = size(x); 
y = zeros(size(x));

dfast = Delta(x,'difference', fastperiod); dslow=Delta(x,'difference', slowperiod);
d1 = Delta(x,'difference', 1);   vslow=VolatilityFunction(d1,'std',slowperiod,3,10e10);
y = (dfast .* dslow) ./ vslow;


    



