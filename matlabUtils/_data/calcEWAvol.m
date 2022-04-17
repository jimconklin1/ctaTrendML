function exwv = calcEWAvol(x,hl,means,seeds,isRets,trLvl,bffrSmpl,dfltVal)

% This function creates an exponentially smoothed volatility 
%   series with half-life 'hl'.  
% Inputs: 
%    x = series
%    hl = half live of exp vol process
%    means = mean used in std calc
%    seeds = If not specified assumed to be zero
%    isRets = true if inputs are return series
%    trLvl = truncation level, in std deviations

gamma = 0.5^(1/hl);
[t n] = size(x);
if nargin < 8 || isempty(dfltVal)
   dfltVal = NaN; 
end

if nargin < 7 || isempty(bffrSmpl)
   bffrSmpl = 25; 
end

if nargin < 6 || isempty(trLvl)
   trLvl = 10; % truncate at 10 standard deviations
end

if nargin < 5 || isempty(isRets)
   isRets = false; 
end

if isRets
   frstActv = calcFirstActive(x,isRets,1.0e-200); 
else 
   frstActv = calcFirstActive(x,isRets); 
end 
if isRets
   dfltVar = zeros(1,n);
else
   dfltVar = nan(1,n); 
end % if
for j=1:n
   if (frstActv(j)+bffrSmpl<=size(x,1))&&(frstActv(j)+1<=size(x,1)) 
      dfltVar(1,j) = nanvar(x(frstActv(j)+1:frstActv(j)+bffrSmpl,j)); 
   else
      if isRets
         dfltVar(1,j) = 0;
      else
         dfltVar(1,j) = NaN; 
      end % if
   end % if
end % for

% handle various cases for seeds:
if nargin < 4 || isempty(seeds)
   for j=1:n
      if frstActv(j) + bffrSmpl > size(x,1) 
         seeds(1,j) = dfltVal; % handle case where a column is all bad data 
      else
         seeds(1,j) = nanstd(x(frstActv(j)+1:frstActv(j)+bffrSmpl,j)); 
      end 
   end % for
elseif sum(seeds)==0 && size(seeds,2)<n
   seeds = zero(1,n);  
elseif size(seeds,2)<n
   for j=size(seeds,2)+1:n
      seeds(1,j) = nanstd(x(frstActv(j):frstActv(j)+bffrSmpl,j));
   end % for    
% else
%    seeds = seeds; % DO NOT convert seeds into variances from stdevs 
end

% handle various cases for means:
if nargin < 3 || isempty(means)
    means = zeros(t,n);
elseif means==0
    means = zeros(t,n);    
end 

var = nan(t,n);
obsVar = (x-means).^2;
for j = 1:n
   if frstActv(j) + bffrSmpl > size(x,1) 
      var(:,j) = dfltVal; % case where a column is all bad data: leave as dfltVal
   else 
      badx = isnan(obsVar(frstActv(j),j));
      if badx
         var(frstActv(j),j) = seeds(1,j).^2;
      else
         var(frstActv(j),j) = gamma .* (seeds(1,j).^2) + (1 - gamma) .* obsVar(frstActv(j),j);
      end % if
      for i = frstActv(j)+1:t
         badx = isnan(obsVar(i,j));
         if badx
            var(i,j)=var(i-1,j);
         else
            % de-kurtose:
            thresh = (trLvl^2)*max(var(i-1,j),dfltVar(1,j)); 
            if obsVar(i,j) > thresh 
               var(i,j) = gamma*var(i-1,j) + (1 - gamma)*thresh; 
            else
               var(i,j) = gamma*var(i-1,j) + (1 - gamma)*obsVar(i,j); 
               dfltVar(1,j) = gamma*dfltVar(1,j) + (1 - gamma)*var(i,j); 
            end % if 
         end % if badx 
      end % for i 
   end % if frstActv(j) + bffrSmpl > size(x,1) 
end % for n
exwv = var.^0.5; 

% Puts NaN's back into the final output
exwv(isnan(obsVar)) = dfltVal; % exwv(find(isnan(obsVar))) = dfltVal; 
end