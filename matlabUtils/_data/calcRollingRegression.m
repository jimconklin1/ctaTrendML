function output = calcRollingRegression(y,X,hl,sampleLength,dataFreq,calcFreq)
if nargin < 6 || isempty(calcFreq)
   calcFreq = 'daily'; 
end % if
if nargin < 5 || isempty(dataFreq)
   dataFreq = 'daily'; 
end % if
if nargin < 4 || isempty(sampleLength)
   sampleLength = 260;
end % if
if nargin < 3
   hl = 1001; 
end % if

[T,N] = size(X);
beta = zeros(T,1);
tStat = zeros(T,1);
rSqr = zeros(T,1); 
dwStat = zeros(T,1); 
if hl>1 && hl <1000
    gamma = 0.5^(1/hl); 
    expWts = gamma.^((T:-1:1))'; 
    X1 = X.*repmat(expWts,[1,N]); 
    y1 = y.*expWts;
else
    X1 = X;
    y1 = y;
end % if

opts = {'beta', 'adjrsquare', 'tstat', 'rsquare','dwstat'};
if strcmpi(calcFreq,dataFreq)
   periodSet = sampleLength+1:T;
elseif strcmpi(calcFreq,'weekly') && strcmpi(dataFreq,'daily')
   periodSet = sampleLength+5:5:T; 
elseif strcmpi(calcFreq,'monthly') && strcmpi(dataFreq,'daily')
   periodSet = sampleLength+21:21:T; 
else 
   disp('dataFreq / calcFreq combination does not meet defined spec; using default dataFreq == calcFreq')
   periodSet = sampleLength+1:T;
end % if

for t = periodSet
  yy = y1(t-sampleLength:t,:); 
  xx = X1(t-sampleLength:t,:); 
  rStats = regstats(yy, xx, 'linear', opts); 
  beta(t,:) = rStats.tstat.beta(2:N+1,:)'; % skip over the intercept
  tStat(t,:) = rStats.tstat.t(2:N+1,:)'; 
  rSqr(t,:) = rStats.rsquare; 
  dwStat(t,:) = rStats.dwstat.dw; 
  %if strcmpi(calcFreq,'daily') && strcmpi(dataFreq,'daily') NOTHING TO
  %  DO... recorded daily 
  if strcmpi(calcFreq,'weekly') && strcmpi(dataFreq,'daily') 
     beta(t-5:t-1,:) = repmat(beta(t,:),[5,1]);
     tStat(t-5:t-1,:) = repmat(tStat(t,:),[5,1]);
     rSqr(t-5:t-1,:) = repmat(rSqr(t,:),[5,1]);
  elseif strcmpi(calcFreq,'biweekly') && strcmpi(dataFreq,'daily') 
     beta(t-11:t-1,:) = repmat(beta(t,:),[11,1]);
     tStat(t-11:t-1,:) = repmat(tStat(t,:),[11,1]);
     rSqr(t-11:t-1,:) = repmat(rSqr(t,:),[11,1]);
  elseif strcmpi(calcFreq,'monthly') && strcmpi(dataFreq,'daily') 
     beta(t-21:t-1,:) = repmat(beta(t,:),[21,1]);
     tStat(t-21:t-1,:) = repmat(tStat(t,:),[21,1]);
     rSqr(t-21:t-1,:) = repmat(rSqr(t,:),[21,1]);
  end 
end % for
beta(1:sampleLength,:) = repmat(beta(sampleLength+1,:),[sampleLength,1]); 
tStat(1:sampleLength,:) = repmat(tStat(sampleLength+1,:),[sampleLength,1]); 
rSqr(1:sampleLength,:) = repmat(rSqr(sampleLength+1,:),[sampleLength,1]); 
beta(periodSet(end)+1:T,:) = repmat(beta(periodSet(end),:),[(T-periodSet(end)),1]); 
tStat(periodSet(end)+1:T,:) = repmat(tStat(periodSet(end),:),[(T-periodSet(end)),1]); 
rSqr(periodSet(end)+1:T,:) = repmat(rSqr(periodSet(end),:),[(T-periodSet(end)),1]); 

beta2 = calcEWA(beta,5,beta(1,:),false);
beta2(isnan(beta2)) = beta(1,:); 
yHat = sum(X.*beta2,2); 

output.beta = beta;
output.tStat = tStat;
output.rSqr = rSqr;
output.yHat = yHat;
output.dwStat = dwStat;
output.resid = y - yHat;
end % fn