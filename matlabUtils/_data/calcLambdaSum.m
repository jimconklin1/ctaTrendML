function xm = calcLambdaSum(x,lambda,seeds,isRets,bffrSmpl,dfltVal)

% This function creates an exponentially smoothed series with a specified half-life.
%
% Function usage is expsmooth(x,hl,seeds) where:
% x		=	the raw data series to be smoothed
% hl    =	the half-life (in number of periods) of the smoothing
% seeds	=	the initial values to be used in the smoothing (optional).  If not supplied, they are set to zero.	
 
[t, n] = size(x); 
gamma = lambda; 

if nargin < 6 || isempty(dfltVal)
   dfltVal = NaN; 
end

if nargin < 5 || isempty(bffrSmpl)
   bffrSmpl = 25; 
end

if nargin < 4 || isempty(isRets)
   isRets = false; 
end
frstActv = calcFirstActive(x,isRets,1e-10); 

% handle various cases for seeds:
if nargin < 3 || isempty(seeds)||sum(isnan(seeds(1,:)))>0
   for j=1:n
      if (frstActv(j)+bffrSmpl)>size(x,1)
         seeds(1,j) = dfltVal; 
      else
         seeds(1,j) = nanmean(x(frstActv(j)+1:frstActv(j)+bffrSmpl,j)); 
      end 
   end % for
elseif sum(seeds)==0 && size(seeds,2)<n
   seeds = zeros(1,n);  
elseif size(seeds,2)<n
   for j=size(seeds,2)+1:n
      seeds(1,j) = nanmean(x(frstActv(j):frstActv(j)+bffrSmpl,j));
      if (frstActv(j)+bffrSmpl)>size(x,1) || isnan(seeds(1,j))
         seeds(1,j) = dfltVal; 
      end 
   end % for    
end

xm = repmat(dfltVal,[t n]);
for j = 1:n
   badx = find(isnan(x(frstActv(j),j)));
   if badx
      xm(frstActv(j),j) = seeds(1,j);
   else
      xm(frstActv(j),j) = gamma .* seeds(1,j) + (1 - gamma) .* x(frstActv(j),j);
   end
   for i = frstActv(j)+1:t
      badx=isnan(x(i,j));
      if badx||(i<frstActv(j))
         xm(i,j)=xm(i-1,j); 
      else
         xm(i,j)=gamma.* xm(i-1,j) + (1-gamma).*x(i,j); 
      end
   end
end % for j
% Puts default values back into the final output
xm(isnan(x)) = dfltVal;
xm = 1/(lambda-1)*xm;
end % fn