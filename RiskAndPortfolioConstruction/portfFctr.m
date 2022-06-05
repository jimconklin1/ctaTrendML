% Regress "mvs"-weighted "returns" on "fctrRet", ignoring future returns 
% past endIdx. The "mvs"-weighting is done as of time endIdx.
% *** PLEASE NOTE SOME ASYMMETRY in input parameters ***
% Factor returns should come here with risk free already stripped.
% This is because only some factors are supposed to get risk free 
% subtracted, and we won't know which ones, inside this function.
% HF returns, on the other hand, should come AS IS (we will strip risk free
% inside this function after the returns have been aggregated)
%
% This funciton was only tested when fctrRet has 1 factor, but it should
% work for multiple factors as well.
%
% Inputs:
% returns[T x N] = returns of funds 1..N over time t = 1..T. Unknown returns
%   (NaNs) should be replaced with zeroes before the call.
% mvs[T x N] = market values of each of N funds at time 1..T. Unknown MVs
%   (NaNs) should be replaced with zeroes before the call.
% fctrRet[T x K] = returns of K market factors over time 1..T.
% rfr[T x 1] = risk-free rate returns.
% endIdx = moment in time at which to perform the regression. (Returns up
% to time t = endIdx, with market values as of t = endIdx.
% 
% Output: regular Matlab regstats. Regression coefficients (alpha, beta[1..K]) 
% can be found in o.tstat.beta where o is the return value.
function o = portfFctr(returns, mvs, fctrRet, rfr, endIdx)
  mvs = mvs(endIdx,:)';
  returns = returns(1:endIdx,:);
  fctrRet = fctrRet(1:endIdx,:);
  rfr = rfr(1:endIdx,:);

  activeFilter = mvs >0;
  mvs = mvs(activeFilter);
  returns = returns(:,activeFilter');
  
  weights = mvs ./ sum(mvs);
  r = returns * weights;
  r = r - rfr;

  o = regstats(r,fctrRet,'linear',{'tstat','fstat','rsquare','dwstat','r'});
end