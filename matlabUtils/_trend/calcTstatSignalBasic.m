function signal = calcTstatSignalBasic(data,fParam) %(data,config,portConfig,fParam,spliceDate,TZ)

% inputs: 
%   data.header
%       .dates
%       .close

% fParam.lookbacks
%       .simStartDate
%       .squashLevelTstat
%       .squashLevelSignal

t0 = find(data.dates >= fParam.simStartDate, 1); 
[T,N] = size(data.close);
K = length(fParam.lookbacks); 
signalCube = zeros(T,N,K); 
normTstatCube = zeros(T,N,K); 
rawTstatCube = nan(T,N,K);
logCumRtn = log(calcCum(data.close, 1));
logCumRtn(isnan(data.close)) = nan; 
tt1 = T;
for k = 1:K
    L = fParam.lookbacks(k);
    X = 1:L; 
    t1 = max([t0,L]);
    for t = t1:T
        Ys = logCumRtn(t-L+1:t,:);
        rawTstatCube(t, sum(~isnan(Ys))/L <0.5, k )= 0 ;
        Ns = find (~isnan(logCumRtn(t,:))& (rawTstatCube(t, :, k )~=0 ));
        for n = Ns
            Y = Ys(:,n); 
            stats= regstats(Y,X,'linear',{'tstat'});%mdl = fitlm(X,Y);
            rawTstatCube(t,n,k)= stats.tstat.t(2);%mdl.Coefficients.tStat(2);
        end % for Ns 
    end % for t 
    normTstatCube(:,:,k)= rawTstatCube(:,:,k)/sqrt(L-1); 
    signalCube(:,:,k) = squashTstat(normTstatCube(:,:,k), fParam); 
    tt1 = min([tt1,t1]); 
end % for k 
tt1 = max([t0,tt1]); 
signal0 = mean(signalCube, 3); 

% structure output variable: 
%t0 = find(data.dates== data2.dates(1));
% t0 =strt_i ; 
signal.assetIDs = data.header; 
signal.dates = data.dates(tt1:end,:); 
signal.values = signal0(tt1:end,:); 
signal.assets = data.header; 
signal.signalCube = signalCube(tt1:end,:,:);
signal.rawTstatCube = rawTstatCube(tt1:end,:,:); 
signal.lookbacks = fParam.lookbacks; 
end % fn
