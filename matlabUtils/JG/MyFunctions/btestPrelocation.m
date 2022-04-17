
function [nsteps, ncols, ptfret, volptf, s, ExecP, nb, wgt, tottrancost, grossreturn, tcforec, GeoEC, ...
   holdPeriodShort, holdPeriodLong, minIncursionShort, maxIncursionLong, beep ] = btestPrelocation(c)

[nsteps,ncols]=size(c);

ptfret=zeros(size(c,1),1);
volptf=zeros(size(c,1),1);
s=zeros(size(c));      % Signals
ExecP=zeros(size(c));  % Execution Prices
nb=zeros(size(c));     % Number of Shares
wgt=zeros(size(c));    % Weightts
tottrancost=zeros(size(c));     
% .. Equity Curve ..
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c));
GeoEC=zeros(size(c)); 
holdPeriodShort = zeros(size(c));
holdPeriodLong = zeros(size(c));  %  Holding Period 
minIncursionShort = zeros(size(c)); 
maxIncursionLong = zeros(size(c)); % Update Minimum Short & Maximum Long
beep = 0.0001; 