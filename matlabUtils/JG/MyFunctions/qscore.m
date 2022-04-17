function[Y,StdY] = QScore(X,Lookback)
%
%__________________________________________________________________________
%
%__________________________________________________________________________
%

%Prelocate the matrix
Y=zeros(size(X));
[nsteps,ncols]=size(X);

% Compute Moving Average
SmoothX=TrendSmoother(X,'ema',Lookback(1,1));

% Difference
SmoothXDiff=RateofChange(SmoothX,'difference',Lookback(1,2));


for j=1:ncols
   % Find First Non Empty Row for Col. j
   StartCol=0;
   for i=1:nsteps
       if ~isnan(X(i,j)) && X(i,j)~=0
           StartCol=i;
           break
       end
   end
   
   for i=StartCol+Lookback(1,1)+Lookback(1,2)+Lookback(1,3)+1:nsteps
       Y(i,j)=sum(SmoothXDiff(i-Lookback(1,3)+1:i,j));
   end
    
end

StdY = VolatilityFunction(Y,'simple volatility',Lookback(1,4),20,10e10);
%clear SmoothX
%clear SmoothXDiff