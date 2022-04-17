function mx = quarterly2monthly(x,mDates,qDates)

% This function converts a quarterly series to a daily series.  The inputs are:
%
% x		=	The daily series to be converted (T x N)
% ddates	=	The series of daily dates in Matlab format that correspond to dx
% qdates	=	The series of quarterly dates in Matlab format that correspond to x

nm = month(mDates); %Matlab function that returns the month in both numeric (1-12) and text form
nq = month(qDates);
my = year(mDates);
qy = year(qDates);
T = length(mDates);
N = size(x,2);

% Rewrite the months from the daily and quarterly date series so that each month in the quarter 
% gets mapped to the middle month of the quarter
nm(nm==1 | nm==3)=2;
nm(nm==4 | nm==6)=5;
nm(nm==7 | nm==9)=8;
nm(nm==10 | nm==12)=11;

nq(nq==1 | nq==3)=2;
nq(nq==4 | nq==6)=5;
nq(nq==7 | nq==9)=8;
nq(nq==10 | nq==12)=11;

mx = nan(T,N); 
for t = 1:T
   map=find(nq==nm(t) & qy==my(t));
   if ~isempty(map)
      mx(t,:)=x(map,:);
   end
end
