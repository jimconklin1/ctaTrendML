% Here is the MATLAB code that one could use to estimate historical volatility using different methods
% 
% Historical Close-to-Close volatility
% Historical High Low Parkinson Volatility
% Historical Garman Klass Volatility
% Historical Garman Klass Volatility modified by Yang and Zhang
% Historical Roger and Satchell Volatility
% Historical Yang and Zhang Volatility
% Average of all the historical volatilities calculated above




function vol = EstimateVol(O,H,L,C,n)
% Estimate Volatility using different methods
% EstimateVol(O,H,L,C)gives an estimate of volatility based on Open, High,
% Low, Close prices.
% INPUTS:
% O--Open Price
% H--High Price
% L--Low Price
% C--Close Price
% n--Number of historical days used in the volatility estimate
% OUTPUT:
% Vol is a structure with volatilities using different methods.
% hccv -- Historical Close-to-Close volatility
% hhlv -- Historical High Low Parkinson Volatility
% hgkv -- Historical Garman Klass Volatility
% hgkvM -- Historical Garman Klass Volatility modified by Yang and Zhang
% hrsv -- Historical Roger and Satchell Volatility
% hyzv -- Historical Yang and Zhang Volatility
% AVGV -- Average of all the historical volatilities calculated above
% web: http://www.sitmo.com
try
OHLC = [O H L C];
catch %#ok
error('O H L C must be of the same size');
rethrow(lasterror);
end
if(n<=length(O))
fh = @(x) x(length(x)-n+1:end);
else
error('n should be less than or equal to the length of the prices')
end
open = fh(O); %O(length(O)-n+1:end);
high = fh(H); %H(length(H)-n+1:end);
low = fh(L); %L(length(L)-n+1:end);
close = fh(C); %C(length(C)-n+1:end);
Z = 252; %Number of trading Days in a year

vol.hccv = hccv();
vol.hhlv = hhlv();
vol.hgkv = hgkv();
vol.hgkvm = hgkvM();
vol.hrsv = hrsv();
vol.hyzv = hyzv();
vol.AVGV = mean(cell2mat(struct2cell(vol)));

function vol1 = hccv()
% historical close to close volatility
%Historical volatility calculation using close-to-close prices.

r = log(close(2:end)./close(1:end-1));
rbar = mean(r);
vol1 = sqrt((Z/(n-2)) * sum((r - rbar).^2));
end

function vol2 = hhlv()
%The Parkinson formula for estimating the historical volatility of an
%underlying based on high and low prices.

vol2 = sqrt((Z/(4*n*log(2))) * sum((log(high./low)).^2));
end

function vol3 = hgkv()
% The Garman and Klass estimator for estimating historical volatility 
% assumes Brownian motion with zero drift and no opening jumps 
%(i.e. the opening = close of the previous period). This estimator is 
% 7.4 times more efficient than the close-to-close estimator. 

vol3 = sqrt((Z/n)* sum((0.5*(log(high./low)).^2) - (2*log(2) - 1).*(log(close./open)).^2));

end

function vol4 = hgkvM()
%Yang and Zhang derived an extension to the Garman Glass historical 
%volatility estimator that allows for opening jumps. It assumes 
%Brownian motion with zero drift. This is currently the preferred 
%version of open-high-low-close volatility estimator for zero drift 
%and has an efficiency of 8 times the classic close-to-close estimator.
%Note that when the drift is nonzero, but instead relative large to the
%volatility, this estimator will tend to overestimate the volatility.

vol4 = sqrt((Z/n)* sum((log(open(2:end)./close(1:end-1))).^2 + (0.5*(log(high(2:end)./low(2:end))).^2) - (2*log(2) - 1)*(log(close(2:end)./open(2:end))).^2));
end

function vol5 = hrsv()
%The Roger and Satchell historical volatility estimator allows for
%non-zero drift, but assumed no opening jump. 

vol5 = sqrt((Z/n)*sum((log(high./close).*log(high./open)) + (log(low./close).*log(low./open))));
end

function vol6 = hyzv()
%Yang and Zhang were the first to derive an historical volatility 
%estimator that has a minimum estimation error, is independent of 
%the drift, and independent of opening gaps. This estimator is 
%maximally 14 times more efficient than the close-to-close estimator. 
%It can be interpreted as a weighted average of the Rogers and Satchell
%estimator, the close-open volatility and the open-close volatility. 
%The performance degrades to the classic close-to-close estimator when
%the price process is heavily dominated by opening jumps. 
muO = (1/n)*sum(log(open(2:end)./close(1:end-1)));
sigmaO = (Z/(n-1)) * sum((log(open(2:end)./close(1:end-1)) - muO).^2);
muC = (1/n)*sum(log(close./open));
sigmaC = (Z/(n-1)) * sum((log(close./open) - muC).^2);
sigmaRS = hrsv();
sigmaRS = sigmaRS^2;
k = 0.34/(1+((n+1)/(n-1)));

vol6 = sqrt(sigmaO^2+(k*sigmaC^2)+((1-k)*(sigmaRS)));

end
end