function [g] = HPFilter(x,lambda)
%
%__________________________________________________________________________
%
% This function compute the Hodrick Prescott Filter
%
% The Hodrick Prescott Filter (HP-Filter) is the most popular method to 
% separate a time series into its components.
% Note tha thefilter suffers from "border effect".
%
% To accelerate the computation the Add-In makes use of the penta-diagonal 
% structure of the coefficient-matrix. So detrending a lot of data points
% is not a problem for this program.
% 
% -- Function required --
% Requires: penta2.m
%
% -- Inputs --
% - x      =    time series
% - lambda = Smoothing parameter 
%            # Daily time series:     lambda >= 3,000,000 (my own estimate)
%            # Monthly time series:   lambad = 14,400
%            # Quarterly time series: lambda = 1,600
%            # Yearly time series:    lambda = 100
% note: Morten O. Ravn & Harald Uhlig, "On adjusting the HPF for the
% frequency of observatins" (The Review of economics & Statistics, May
% 2002, 842(2): 371-380), suggest using lambda = 6.25 for yearly data and 
% lambda = 129,400 for monthly data.
%
% -- Output --
% g is the trend component
%
% Author: Kurt Annen annen@web-reg.de
% Date: 15/05/2004
% Internet: www.web-reg.de
%__________________________________________________________________________
%
%
tic
if nargin < 2
    error('Requires at least two arguments.');
end

[m,n] = size (x);
if m < n
    x = x';     
    m = n;
end

a(1)=lambda+1;
a(2)=5*lambda+1;
a(3:m-2)=6*lambda+1;
a(m-1)=5*lambda+1;
a(m)=lambda+1;
b(1)=-2*lambda;
b(2:m-2)=-4*lambda;
b(m-1)=-2*lambda;
c(1:m-2)=lambda;

g=penta2(x,a,b,c);
    if nargin == 3     
        plot(g,'r');   grid on;   hold on;   plot(x);   title(['HP-Filter']);
    end
end
%toc