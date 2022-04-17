function[MinTs,MaxTs,DistToMin,DisToMax,MADistToMin,MADisToMax,MA2DistToMin,MA2DisToMax] =  BreakoutFinderOld(h,l,c,method,Period,Lag, PeriodSmooth, PeriodSmooth2)

%__________________________________________________________________________
%
% This function computes the Min & the Max over a given period then
% computes the distance form the current observed to this Min and Max. 
%
% INPUT
%
% X                   = price
% Period              = period for Fanalysis
% Lag                 = lag for difference
%
% OUTPUT
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
x=c;
[nsteps,ncols]=size(x);
MinTs = zeros(size(x));             MaxTs = zeros(size(x));
DistToMin = zeros(size(x));         DisToMax= zeros(size(x));

% Min & Max time series----------------------------------------------------
Y = zeros(size(x));
for j=1:ncols
    % find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(h(i,j)) &&  ~isnan(l(i,j)) &&  ~isnan(c(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Moving average
    for k=start_date(1,1)+Period+1+Lag:nsteps
        MinTs(k,j)=min(l(k-Period+1-Lag:k-Lag,j));
        MaxTs(k,j)=max(h(k-Period+1-Lag:k-Lag,j));        
    end
end

% Distance to Min & Max----------------------------------------------------
switch method
    case 'difference'
        DistToMin = c - MinTs;  
        DistToMax = c - MaxTs; 
    case 'percentage'
        DistToMin = c ./ MinTs - ones(size(c));  
        DistToMax = c ./ MaxTs - ones(size(c));  
end
MADistToMin=expmav(DistToMin,PeriodSmooth);
MADisToMax=expmav(DistToMax,PeriodSmooth);
MA2DistToMin=amav(MADistToMin,PeriodSmooth2);
MA2DisToMax=expmav(MADisToMax,PeriodSmooth2);    