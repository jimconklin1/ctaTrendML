function v = calcRollingVol(x,d,muX)
[T, N] = size(x);
if nargin < 3 || muX~=0
    muX = calcLDW(x,d);
else 
    muX = zeros(T,N); 
end
y = (x - muX).^2; 
v = zeros(T,N); 
if d >= T 
   v = repmat(nanstd(y),[1,T]);
else
   for t = 1:d-1
      temp = y(1:t,:);
      v(t,:) = nanmean(temp); 
   end % t
   for t=d:T
      temp = y(t-d+1:t,:);
      v(t,:) = nanmean(temp); 
   end
end % if
v = v.^(0.5); 
end % fn