function[y,yir] = infocoef(f,x,lookback)
%
%__________________________________________________________________________
%
% The function compute the information coefficient whici is a formal measure
% of forecasting alpha power.
% It is a linear statistics that measures the cross-sectional correlation
% between the security return coming from a factor and the subsequent
% actual returns for securities.
% IC is important in evaluating factors because of its translation into IR.
% IR = IC / std(IC)
%
% INPUT--------------------------------------------------------------------
% x       = matrix of price
% lokback = lokkback for conputing lag between factors and return

% OUTPUT-------------------------------------------------------------------
% y   = information coefficient
% yir = information ratio
%__________________________________________________________________________

% Define dimension & Prelocate matrix
[nsteps,ncols] = size(x); 
y = zeros(nsteps,1);
yir=zeros(nsteps,1);

xr = Delta(x,'roc',lookback);

for i= lookback:nsteps
    y(i,1)=corr(f(i-lookback+1,:), xr(i,:));
    yir(i,1)=y(i,1)/stdev(f(i-lookback+1,:));
end




