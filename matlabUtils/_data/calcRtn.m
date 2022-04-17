function [rtn] = calcRtn(x)
% This function calculates the returns on a price series x, 
%   e.g., rtn(t) = x(t)/x(t-1) - 1; 
% 
% Note, if the inpute price series has zeros, nans, etc., 
%   the function must go back to the last good price series.
% 
% Output: because output is returns, no-values are 0, not NaN.

[T,N] = size(x); 
rtn = zeros(T,N); 
x = rmNaNs(x); 
iTemp = isinf(x); 
x(iTemp) = 0;
for n = 1:N
%   indx = find(~(isnan(x(:,n)) | isinf(x(:,n))));  
%   temp = x(indx,n);
%   rtn(indx(2:end)) = temp(2:end,:)./temp(1:end-1,:) - 1;
   t0 = findFirstGood(x(:,n),0,1.0e-25); 
   for t = t0+1:length(x)
      if x(t,n) == 0
         x(t,n) = x(t-1,n);
      else 
         rtn(t,n) = x(t,n)./x(t-1,n) -1; 
      end % if
   end % for t
end % for n

end % fn