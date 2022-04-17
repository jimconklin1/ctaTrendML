function [mu_h, sigma_h] = RollingGenhurst(x, RollingPeriod, q, maxT)
%
%__________________________________________________________________________
%
% This function computes the Generalized Hurst Exponent over a Rolling 
% Window for a given period.
% This function makes use of the 'genhurst' function. 
%
%
% -- Inputs --
% x = time series
% LookbackPeriod = The lookback period used in the Range-Scale algorithm
%                  to compute a point estimate of Hurst in time "t". The
%                  algorithm takes a time series of length "l" (ie. Rolling
%                  Window) and for a given Lookcback period compute the
%                  Hurst exponent.
% 'method' refers to the methud used in the 'RSana' function:
%        # 'Hurst' for the Hurst-Mandelbrot variation.
%        # 'Lo' for the Lo variation.
%        # 'MW' for the Moody-Wu variation.
%        # 'Parzen' for the Parzen variation.
% RollingWindow  = Rolling Window over which the Hurst's Exponent is 
%                  computed. i.e. length of the time series
% -- Output --
% hurst is the Hurst's exponent
%
%__________________________________________________________________________
%
%
% -- Prelocate matrices & Dimensions --
[nsteps,ncols]=size(x);
mu_h = zeros(size(x));    
sigma_h = zeros(size(x)); 

if nargin < 3, q = 1; maxT = 19; end
if nargin < 4,  maxT = 19; end

for j=1:ncols
    for i = RollingPeriod : nsteps
        x_snap = x(i-RollingPeriod+1:i,j);
        [mH,sH] = genhurst(x_snap, q, maxT);
        mu_h(i,j) = mH;
        sigma_h(i,j) = sH;
    end
end    