function [y] = ma(x, n, opt1, opt2, seeds)
% function computes moving averages
% x = time series
% n = # of days of moving average sample, or halflife
% opt1 = "e", or exponential, "s" or simple, "w" or weighted (i.e. [4, 3, 2, 1]/(4+3+2+1) ). 
% opt2 = "level" or "slope"

if (nargin < 4)||isempty(opt2)
    opt2 = 'level';
end

if (nargin < 3)||isempty(opt1)
    opt1 = 's';
end

[t m] = size(x);
fred = 0;

if nargin == 5
  fred = 1;
  [~, m2] = size(seeds);
  if m2 > m
    seeds = seeds(:,m);
  elseif m2 < m
    seeds = repmat(seeds(1),[1 m]);
  end % if
end % if

y = NaN(t,m);
if (n > t) && strcmp(opt1,'s')  
    disp('n is greater than length of sample; sample mean returned as argument.')
    y = repmat(nanmean(x),t);
else 
    if fred 
        y(1:n,:) = repmat(seeds,[n 1]);
    else
      y(1:n,:) = repmat(nanmean(x(1:n,:)),[n 1]);
    end % if fred
    switch opt1
        case 's' 
            yTemp =calcMA(x,n); 
            y(n+1:end,:) = yTemp(n+1:end,:); 
%             for i = n+1:t
%                 y(i,:) = nanmean(x(i-n:i,:));
%             end % for i
        case 'e' 
            y(n+1:end,:) = calcEWA(x(n+1:end,:),n,y(n,:));
        case 'w' 
            a = (n-(0:n-1))/(sum(1:n));
            for i = n+1:t
                y(i,:) = a*x((i-n+1):i,:);
            end % for i
    end % switch 
    if strcmp(opt2,'slope')
        y = [zeros(1,m); (y(2:end,:) - y(1:end-1,:))./y(1:end-1,:)];
    end % if strcmp(opt2,'slope')
end % if strcmp(opt1,'mean') & n > t 