ciqData = readtable('Data.csv');
ciqData.IQ_PAYOUT = ciqData.IQ_DIV_SHARE - ciqData.CF_DECR_CAP_STOCK - ciqData.CF_INCR_CAP_STOCK;
ciqData.BBG_BB = - ciqData.CF_DECR_CAP_STOCK - ciqData.CF_INCR_CAP_STOCK;

INCOME_STATEMENT = 6 : 14;
BALANCE_SHEET = 15 : 22;
CASH_FLOW = 23 : 25;
RATIOS = 26 : 31;

%% 
y0 = ciqData.IQ_PAYOUT; % IQ_DIV_SHARE, DVD_SH_12M, IQ_BB, IQ_PAYOUT
X0 = ciqData.IQ_EBITDA; % IQ_EBIT, IQ_BASIC_EPS_EXCL, 
y = y0(2:end,1); 
X = [y0(1:end-1,1),X0(2:end,1)]; 
o = regstats(y,X,'linear',{'tstat','r','yhat','dwstat','rsquare'}); 
rho = autocorr(o.r,'NumLags',2); 
% Output Arguments:
%   acf - Sample ACF. Vector of length NumLags+1 of values computed at lags
%       0,1,2,...,NumLags. For all y, acf(1) = 1 at lag 0.
%   lags - Vector of lag numbers of length NumLags+1 used to compute acf.
%   bounds - Two-element vector of approximate upper and lower confidence
%       bounds, assuming that y is an MA(NumMA) process.
%   h - Vector of handles to plotted graphics objects. AUTOCORR plots the
%       ACF when the number of output arguments is 0 or 4.

% spec 2
y = y0(3:end,1); 
X = [y0(2:end-1,1),y0(1:end-2,1),X0(3:end,1)]; 
o = regstats(y,X,'linear',{'tstat','r','yhat','dwstat','rsquare'}); 
figure(1); plot(X(:,3),y,'x')
figure(2); plot(X(:,3),o.yhat,'x')
figure(3); plot(X(:,3),o.r,'x')

% spec 3
y = y0(3:end,1); 
X = [y0(2:end-1,1),(y0(2:end-1,1)-y0(1:end-2,1)),X0(3:end,1),(X0(3:end,1)-X0(2:end-1,1))]; 
o = regstats(y,X,'linear',{'tstat','r','yhat','dwstat','rsquare'}); 
figure(1); plot(X(:,3),y,'x')
figure(2); plot(X(:,3),o.yhat,'x')
figure(3); plot(X(:,3),o.r,'x')

