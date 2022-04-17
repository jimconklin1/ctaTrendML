function signal = calcMomSignalBasic(data,fParam)
% calcMomSignalBasic is a simple momentum kernel with a mixture of
% parameters

% data.header, data.dates, data.values, where field 'values' are close returns
% fParam.nearZeroOption = a feature that staggers entry and exits when
%                         average returns are near zero, to reduce turnover
% fParam.a = the range of look-backs used in the mix of momentum signals 

if isfield(fParam,'nearZeroOption')
   nrZeroOpt = fParam.nearZeroOption; 
else
   nrZeroOpt = false;
end

[T,N] = size(data.values);
K = length(fParam.a); 
signalCube = zeros(T,N,K); 
signal1 = zeros(T,N);
rtns0 = rmNaNs(data.values,0); 
if nrZeroOpt
   %              calcEWAvol(x,hl,means,seeds,isRets,trLvl,bffrSmpl,dfltVal)
   dailyVol = 0.5*calcEWAvol(rtns0,42,0,nanstd(rtns0(1:260,:)),true,4,260) + ...
              0.5*calcEWAvol(rtns0,260,0,nanstd(rtns0(1:260,:)),true,4,260); 
   dailyVol = rmNaNs(dailyVol,0.0075); % replace initial NaNs w/ 12% ann vol 
end % if

for k = 1:K
   L = fParam.a(k);
   mom0 = ma(rtns0,L);% basic momentum 
   signal0 = sign(mom0); % discretized momentum signal
   if nrZeroOpt
      % force signal to zero IF momentum is near zero AND the signal is
      %   changing.  Otherwise, use the raw signal.
      zeroFilt0 = sqrt(L)*abs(mom0)./dailyVol < 0.15; % momentum is near zero
      for t=2:size(rtns0,1)
         for kk=1:size(rtns0,2)
            if zeroFilt0(t,kk) 
               if signal0(t-1,kk)==0
                  signal0(t,kk) =0; 
               elseif signal0(t-1,kk)<0
                  if mom0(t,kk)<0
                     signal0(t,kk) = -1;
                  elseif mom0(t,kk)>=0
                     signal0(t,kk) = 0;
                  end % if                   
               else % signal0(t-1,kk)>0
                  if mom0(t,kk)>0
                     signal0(t,kk) = 1;
                  elseif mom0(t,kk)<=0
                     signal0(t,kk) = 0;
                  end % if                   
               end % if 
            end % if
         end % for kk
      end % for t
   end % if 
% ll=0; ll=ll+1; figure(1); plot([sign(mom0(:,ll)),signal0(:,ll)]); grid; figure(2); plot([10*calcCum(rtns0(:,ll),0),sqrt(L)*mom0(:,ll)./dailyVol(:,ll)]); grid;
   signal1 = signal1 + signal0/K; 
   signal0(isnan(data.values))= nan; 
   signalCube(:,:,k) = signal0; 
end % for 

signal1(isnan(data.values))=nan; 
% structure output variable: 
signal.assetIDs = data.header; 
signal.dates = data.dates; 
signal.values = signal1; 
signal.assets = data.header; 
signal.sigCube = signalCube; 
signal.lookbacks = fParam.a; 
% auxCalcs = signalCube; 
end % fn