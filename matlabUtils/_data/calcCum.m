function [cum] = calcCum(x,opt)
% this function cumulates values of the variable x, 
%   e.g., cum(x(t+1)) = x(t+1) + cum(x(t)).
% 
% inputs:
%   opt: if 0 arithmetic cumulation
%        if 1 geometric cumulation 
%
[T,N] = size(x); 
if nargin<2||isempty(opt)||opt~=1
   opt = 0; 
end % if
switch opt
   case 0  
      cum = zeros(size(x)); 
      cum(1,:) = x(1,:); 
      for t=2:T
         cum(t,:) = nansum([cum(t-1,:); x(t,:)]);  
      end % for
   case 1
      cum = ones(T,N) + x; 
      cum(isnan(cum)) = 1;
      for t=2:T
         cum(t,:) = cum(t-1,:).*cum(t,:);  
      end % for
      %cum = cum - ones(T,N); 
end % switch