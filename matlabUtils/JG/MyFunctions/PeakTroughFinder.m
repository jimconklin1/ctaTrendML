function [peakX, peakXt, troughX, troughXt] = PeakTroughFinder(x,PeriodMAStd,NbStd, lag)
%
%--------------------------------------------------------------------------
%
% max finder looks for the minimum over a rolling period or since the start
% of the time series
%--------------------------------------------------------------------------
%
peakX = zeros(size(x)); peakXt = zeros(size(x));
troughX = zeros(size(x)); troughXt = zeros(size(x));
[nsteps,ncols]=size(x);
%
%PeriodMAStd=40;NbStd=2;lag=2;

[lb,ub,~,~] = BollingerFunction(x,'a',PeriodMAStd,PeriodMAStd,10e10,-NbStd,NbStd);
lbl=zeros(size(lb));ubl=zeros(size(ub));
for j=1:ncols
    lbl(lag:nsteps,j) = [zeros(lag-1,1);lb(1:nsteps-lag,j)];
    ubl(lag:nsteps,j) = [zeros(lag-1,1);ub(1:nsteps-lag,j)];
end

difflbl = x-lbl;
diffubl = x-ubl;

for j=1:ncols
    for i=2:nsteps
        if difflbl(i,j) > 0 && difflbl(i-1,j)<0
            troughX(i,j)=x(i-1,j);
            troughXt(i,j)=i-1;
        else
            troughX(i,j)=troughX(i-1,j);
            troughXt(i,j)=troughXt(i-1,j);            
        end
        if diffubl(i,j) < 0 && diffubl(i-1,j)>0
            peakX(i,j)=x(i-1,j);
            peakXt(i,j)=i-1;
        else
            peakX(i,j)=peakX(i-1,j);
            peakXt(i,j)=peakXt(i-1,j);            
        end        
    end
end

distup = x - peakX;
distlow = x - troughX;
signdist = -sign(distup-distlow);

    