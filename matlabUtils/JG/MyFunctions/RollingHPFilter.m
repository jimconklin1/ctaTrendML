function [trendc, cyclec] = RollingHPFilter(x, RollingWindow, lambda)
%
%__________________________________________________________________________
%
% This function compute the Hodrick Prescott Filter
%
% The Hodrick Prescott Filter (HP-Filter) is the most popular method to 
% separate a time series into its components.
% Note tha the filter suffers from "border effect".
%
% To accelerate the computation the Add-In makes use of the penta-diagonal 
% structure of the coefficient-matrix. So detrending a lot of data points
% is not a problem for this program.
% 
% -- Functions required --
% HPFilter
% penta2.m
%
% -- Inputs --
% - x      =    time series
% - lambda = Smoothing parameter 
%            # Daily time series:     lambda >= 3,000,000 (my own estimate)
%            # Weekly time series:    lambda = 270,000
%            # Monthly time series:   lambad = 14,400
%            # Quarterly time series: lambda = 1,600
%            # Yearly time series:    lambda = 100
% note: Morten O. Ravn & Harald Uhlig, "On adjusting the HPF for the
% frequency of observatins" (The Review of economics & Statistics, May
% 2002, 842(2): 371-380), suggest using lambda = 6.25 for yearly data and 
% lambda = 129,400 for monthly data.
%
% -- Outputs --
% trendc is the trend component
% cyclec is the cycle component
%
% Joel Guglietta - October 2013
%__________________________________________________________________________
%
%
% -- Prelocate matrices & Dimensions --
[nsteps,ncols]=size(x);
cyclec = zeros(size(x));  
trendc = zeros(size(x));  
%
% -- Compute Rolling HPF --
for j=1:ncols
    % Find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j))
            start_date(1,1) = i;
        break               
        end                                 
    end
    % Compute cyclical component
    for i = start_date(1,1) + 1 + RollingWindow : nsteps
        % Extract vector
        xv = x(i - RollingWindow + 1 : i , j);
        hpfc = HPFilter(xv,lambda); % trend estimate
        trendc(i,j) = hpfc(length(hpfc),1); % fecth last point of trend est.
    end
    % Compute Trend component
    cyclec(start_date(1,1) + 1 + RollingWindow : nsteps,j) = ...
        x(start_date(1,1) + 1 + RollingWindow : nsteps,j) - ...
        trendc(start_date(1,1) + 1 + RollingWindow : nsteps,j);
end    