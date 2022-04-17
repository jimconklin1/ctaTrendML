function v = calcLDW(x,d)
[T, N] = size(x);
v = zeros(T,N); 
wtVec = (1:d)'/sum(1:d);
if d >= T
   for t = 1:T
      wtVec2 = wtVec(d-t+1:d)/sum(wtVec(d-t+1:d)); 
      temp = x(1:t,:).*repmat(wtVec2,[1,N]);
      v(t,:) = nanmean(temp); 
   end % t
else
   for t = 1:d-1
      wtVec2 = (1:t)'/sum(1:t);
      temp = x(1:t,:).*repmat(wtVec2,[1,N]);
      v(t,:) = nansum(temp); 
   end % t
   for t=d:T
      temp = x(t-d+1:t,:).*repmat(wtVec,[1,N]);
      v(t,:) = nansum(temp); 
   end
end % if