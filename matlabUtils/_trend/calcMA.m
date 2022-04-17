function ma = calcMA(data, lookback)
% a wrapper for the fn "filter"
wts = ones(lookback, 1) / lookback;
ma = filter(wts, 1, data);
% fill in buffer:
t0 = findFirstGood(data,NaN);
tt0 = findFirstGood(ma,NaN);
for n = 1:length(t0)
   ma(t0:tt0,n) = repmat(nanmean(data(t0:tt0,n)),[(tt0-t0+1),1]); 
end % for 
end % fn
