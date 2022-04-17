function firstActives = calcFirstActive(x, isRets, toler)
% calculate first active positions of clean price series (no NAs)

if nargin < 3, toler = 0; end
if nargin < 2, isRets = false; end
[nObs nAssets] = size(x);
firstActives = ones(1, nAssets);
for n=1:nAssets
    lastPrice = x(nObs,n);
    x(nObs,n) = 123479.65; % insert temporary stopper
    if isRets, base = 0;
    else base = x(1,n); end
    k = 1;
    if isnan(base)
      while isnan(x(k,n)), k = k + 1; end
      firstActives(1,n) = k;  
    else
      if toler<=0, 
         while x(k,n) == base, k = k + 1; end
      else
         while abs(x(k,n) - base) < toler, k = k + 1; end 
      end % if
      firstActives(1,n) = k;  
      x(nObs,n) = lastPrice; % reset last price
    end % if
end % for