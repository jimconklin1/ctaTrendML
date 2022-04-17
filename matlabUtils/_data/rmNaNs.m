function y = rmNaNs(x,defValue,maxNan2bReplaced)
% This function replaces NaNs in a matrix x.
%   In the first row (x(1,:)), it replaces a Nan
%   with defValue; in subsequent rows, it replaces 
%   NaNs in x(t,:) with the corresponding column 
%   value in x(t-1,:).  maxNan2bReplaced is option
%   to limit the number of nans that can be replaced, 
%   so that back to nan after hitting the limit.
if nargin<2 || isempty(defValue)
   defValue = zeros(1,size(x,2));
end % if
if size(x,2) > 1 && size(defValue,2) < 2
   defValue = repmat(defValue(1,1),[1,size(x,2)]); 
end 
T = size(x,1);
y = x; 
indx = isnan(x(1,:)); 
y(1,indx) = defValue(1,indx); 
for t = 2:T
  indx = isnan(x(t,:)); 
  y(t,indx) = y(t-1,indx); 
end % for t

%option to limit the number of NaNs which are replaced. 
if nargin ==3 
    cnt = zeros (size (x));
    for i =1 :size (x,1)
        if i ==1 
            cnt(i,:)= isnan(x(i,:));
        else 
            cnt(i,isnan(x(i,:)))= cnt(i-1,isnan(x(i,:))) +ones(1, sum(isnan(x(i,:))));
        end 
    end 
    y(cnt>maxNan2bReplaced)= nan; 
end 
end % fn