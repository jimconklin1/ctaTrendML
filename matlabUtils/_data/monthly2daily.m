function dx = monthly2daily(x,ddates,mdates)
% This function converts a monthly series to a daily series.  The inputs are:
%
% x		=	The daily series to be converted (T x N)
% ddates	=	The series of daily dates in Matlab format that correspond to dx
% mdates	=	The series of monthly dates in Matlab format that correspond to x

nd = monthJC(ddates,0); % Matlab function that returns the month in both numeric (1-12) and text form
nm = monthJC(mdates,0);
dy = year(ddates);
my = year(mdates);
T = length(ddates);
N = size(x,2);
dx = nan(T,N);
for i=1:T
   map = find(nm==nd(i) & my==dy(i));
   if ~isempty(map)
      dx(i,:)=x(map,:);
   else
      dx(i,:)=nan(1,N);
   end
end
