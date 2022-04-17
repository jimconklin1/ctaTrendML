function lagx = lagseries(x,lagper,nullVal,Tdim)
% Function lags a series (x) 'lagper' periods, filling in NaN's 
% where there is no data.  Handles both 2-dimensional (T x N) and 
% 3-dimensional (T x N x N) matrices; if Tdim ~= last, you specify it.

if nargin<3 || isempty(nullVal)
   nullVal = NaN; 
end
if nargin<4 || isempty(Tdim)
   Tdim = 1;
end 
if length(size(x))==2
    if Tdim == 1
       [~, n] = size(x);
       lagx = [repmat(nullVal,[lagper,n]); x(1:end-lagper,:)];
    elseif Tdim == 2
       [n, ~] = size(x);
       lagx = [repmat(nullVal,[n, lagper]); x(:,1:end-lagper)];        
    end   
else
   if Tdim == 1
      [~, n1, n2] = size(x);
      lagx = cat(Tdim,repmat(nullVal,[lagper, n1, n2]),x(1:end-lagper,:,:));
   elseif Tdim == 2
      [n1, ~, n2] = size(x);
      lagx = cat(Tdim,repmat(nullVal,[n1, lagper, n2]),x(:,1:end-lagper,:));
   elseif Tdim == 3
      [n1, n2, ~] = size(x);
      lagx = cat(Tdim,repmat(nullVal,[n1, n2, lagper]),x(:,:,1:end-lagper));
   end 
end