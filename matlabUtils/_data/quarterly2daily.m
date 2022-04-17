function dx = quarterly2daily(x,ddates,qdates)

% This function converts a quarterly series to a daily series.  The inputs are:
%
% x		=	The daily series to be converted (T x N)
% ddates	=	The series of daily dates in Matlab format that correspond to dx
% qdates	=	The series of quarterly dates in Matlab format that correspond to x

%nd = month(ddates);  %Matlab function that returns the month in both numeric (1-12) and text form
nd = month_v3(ddates,0);
%nq = month(qdates);
nq = month_v3(qdates,0);
dy=year(ddates);
qy=year(qdates);
t=length(ddates);
n=size(x,2);

% Rewrite the months from the daily and quarterly date series so that each month in the quarter 
% gets mapped to the middle month of the quarter
nd(nd==1 | nd==3)=2;
nd(nd==4 | nd==6)=5;
nd(nd==7 | nd==9)=8;
nd(nd==10 | nd==12)=11;
nq(nq==1 | nq==3)=2;
nq(nq==4 | nq==6)=5;
nq(nq==7 | nq==9)=8;
nq(nq==10 | nq==12)=11;


for i=1:t
   map=find(nq==nd(i) & qy==dy(i));
   if ~isempty(map)
      dx(i,:)=x(map,:);
   else
      dx(i,:)=repmat(NaN,1,n);
   end
end
