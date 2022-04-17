
%__________________________________________________________________________
%
% This function computes all the factors used to build the signals
%
%__________________________________________________________________________
%

function factors = computeFactors(dataSet, configData) 

% -- create structure --
factors = struct;

% -- Extract data from structure --
% - date - 
startDate = dataSet.startDate;
endDate = dataSet.endDate;
dateBenchNum = dataSet.dateNum;
dateBench = dataSet.dateBench;
% - price - 
o = dataSet.o;
h = dataSet.h;
l = dataSet.l; 
c = dataSet.c;
cf = dataSet.cf;

[nsteps,ncols] = size(c);

% -- Compute VRP --
% compute vrp
spret = Delta(cf(:,1),'roc',1); 
realVolspret = 100*power(252,0.5)*VolatilityFunction(spret,'std', 30, 30, 10e10); 
vrp = cf(:,2) - realVolspret;
factors.vrp = vrp;
zvrp = ZScore(vrp,'arithmetic',20,[-3,3],1);
factors.zvrp = zvrp;

% factors for regression
c5dr = Delta(c,'roc',5);
c1mr = Delta(c,'roc',21);
c3mr = Delta(c,'roc',3*21);
c6mr = Delta(c,'roc',6*21);
c12mr = Delta(c,'roc',12*21);
% sp6mr = Delta(cf(:,1),'roc',6*21);
% sp12mr = Delta(cf(:,1),'roc',12*21);
% dxy6mr = Delta(cf(:,3),'roc',6*21);
% dxy12mr = Delta(cf(:,3),'roc',12*21);
% co6mr = Delta(cf(:,4),'roc',6*21);
% co12mr = Delta(cf(:,4),'roc',12*21);
% slope1y2y = cf(:,5)-cf(:,6);
% d6mslope1y2y = Delta(slope1y2y,'d',6*21);
% d12mslope1y2y = Delta(slope1y2y,'d',12*21);
factors.c5dr = c5dr;
factors.c1mr = c1mr;
factors.c6mr = c6mr;
factors.c3mr = c3mr;
factors.c12mr = c12mr;
factors.c6mr = c6mr;

% -- Build purified momentum --
% mompure = zeros(size(c));
%     % exogenous facotrs
%     instReturn = c12mr;
%     % explaining factors
%     f1Ret = sp12mr; 
%     f2Ret = dxy12mr;
%     f3Ret = co12mr;
%     f4Ret = d12mslope1y2y;%dslope1y2y
%     lookbackReg = 21;
% for j=1:ncols
%     instReturnSnap = instReturn(:,j);
%     tsStart = StartFinder(instReturnSnap, 'znan');
%     for i=tsStart + lookbackReg : nsteps
%         ySnap = instReturnSnap(i- lookbackReg+1:i);
%         xSnap = [f1Ret(i- lookbackReg+1:i), f2Ret(i- lookbackReg+1:i), ...
%                  f4Ret(i- lookbackReg+1:i)] ;
%         thresh = size(xSnap,2);
%         b = regress(ySnap,xSnap);
%         if size(b,1)==thresh && size(b,2)==1
%             mompure(i,j) = ySnap(size(ySnap,1)) - xSnap(size(xSnap,1),:) * b ;
%         else
%             mompure(i,j) = mompure(i-1,j);
%         end
%     end
% end
% clear i j
% mompure12m = mompure;
% residmom12m = c12mr - mompure12m;
% factors.mompure12m = mompure12m; 
% factors.residmom12m = residmom12m; 
% 
% % Now nominal rank
% mompureRk = zeros(size(c));
% for i = lookbackReg : nsteps
%     mompureSnap = mompure(i,:);
%     if  nnz(~mompureSnap) == 10
%         mompureRk(i,:) = zeros(1,ncols);
%     else
%         Q = NominalRank(mompureSnap','excel')';
%         mompureRk(i,:) = Q; 
%     end
% end
% factors.mompureRk = mompureRk;

% -- Trend stability --
[k,kpv] = MannKendallTs(c,'rolling', 200,0.05);
factors.kpv = kpv;
% pkpv = RollingPercentile(kpv , 256);
% factors.pkpv = pkpv;
%vrt =  RollingVRTest(c, 100,'hom');
% pvrt  = RollingPercentile(vrt , 256);
% factors.pvrt = pvrt;

% Monthly volatility of one day returns
r1d = Delta(c,'roc',1);
volat = 16*VolatilityFunction(r1d,'std', 100, 100, 10e10);
factors.volat = volat;
%   


    