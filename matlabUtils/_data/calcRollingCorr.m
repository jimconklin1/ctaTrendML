function correl = calcRollingCorr(x,k)
[T,N] = size(x);
correl = nan(N,N,T);
for t = k+1:T
   t0 = t-k;
   t1 = t;
   XX = x(t0:t1,:);
   XX(isnan(XX))=0;
   temp = corr(XX);
   correl(:,:,t) = temp;
end %for