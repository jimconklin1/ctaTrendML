function [o,oStats] = orthogonalizeFactor(factorData,factorHeader,targetFactorHeader,orthoFactorHeader,mode,intercept,opt)
% factor data is n x k
% targetFactorHeader is a cell(string) identifying a single column of factorData
% orthoFactorHeader is 1 x m cell(string) identifying m columns of
%      factorData with which targetFactor must be orthogonal
% mode = {'InSample'} or {'OutOfSample'}
if nargin < 7||isempty(opt)
   opt = 'prod';
end

if nargin < 6
   intercept = true;
end

n = size(factorData,1);
m = size(orthoFactorHeader,2);

%prepare data
y0 = factorData(:,find(strcmp(factorHeader,targetFactorHeader),1));
if intercept
   X = ones(n,m+1);
   for i=1:m
      X(:,i+1) = factorData(:,find(strcmp(factorHeader,orthoFactorHeader(i)),1));
   end
else
   X = ones(n,m);
   for i=1:m
      X(:,i) = factorData(:,find(strcmp(factorHeader,orthoFactorHeader(i)),1));
   end
end
o = nan(size(y0)); 

% Make sure we leave NaNs alone. If we don't do this, the whole output will
% be NaN
naFilter = [isnan(y0),isnan(X)];
naFilter = sum(naFilter,2)==0;
y = y0(naFilter,:);
X = X(naFilter,:);

%orthogonalize
b = 0.970588;  %Equivalent to 3M lookback
if strcmp(mode, "InSample") && strcmp(opt,"prod") 
    eps = y-X*(X'*X\X'*y);  %residual
    oStats = NaN;
elseif strcmp(mode, "InSample") && strcmp(opt,"research") 
    stats = regstats(y,X,'linear',{'tstat','rsquare','r','fstat','dwstat'});  %residual
    eps = stats.r;
    oStats.tstat = stats.tstat;
    oStats.tstat = stats.tstat;
    oStats.fstat = stats.fstat;
    oStats.rsquare = stats.rsquare;
else
    eps =  recursiveLeastSquares(X,y,b);
    oStats = NaN;
end
o(naFilter,:) = eps;
end 