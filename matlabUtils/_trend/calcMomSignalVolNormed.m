function signal = calcMomSignalVolNormed(data,fParam)
% calcMomSignalBasic is a simple momentum kernel with a mixture of
% parameters

% data.header, data.dates, data.values, where field 'values' are close returns
% fParam.a = the range of look-backs used in the mix of momentum signals 

[T,N] = size(data.values);
K = length(fParam.a); 
signalCube = zeros(T,N,K); 
signal1 = zeros(T,N);
rtns0 = rmNaNs(data.values,0); 
dailyVol = 0.5*calcEWAvol(rtns0,42,0,nanstd(rtns0(1:260,:)),true,4,260) + ...
              0.5*calcEWAvol(rtns0,260,0,nanstd(rtns0(1:260,:)),true,4,260); 
dailyVol = rmNaNs(dailyVol,0.0075); % replace initial NaNs w/ 12% ann vol 

for k = 1:K
   L = fParam.a(k);
   mom0 = ma(rtns0,L);% basic momentum 
   signal0 = sqrt(L)*mom0./dailyVol; % normed momentum signal
   signal1 = signal1 + signal0/K; 
   signal0(isnan(data.values))= nan; 
   signalCube(:,:,k) = signal0; 
end % for 

signal1(isnan(data.values))=nan; 
% structure output variable: 
signal.assetIDs = data.header; 
signal.dates = data.dates; 
signal.values = signal1; 
signal.vols = dailyVol; 
signal.sigCube = signalCube; 
signal.lookbacks = fParam.a; 
% auxCalcs = signalCube; 
end % fn