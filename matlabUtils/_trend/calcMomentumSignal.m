function [signal, auxCalcs] = calcMomentumSignal(data,config,dataConfig,portConfig,fParam,spliceDate) %#ok
% calcMMATrendSignal2 is nearly identical to calcMMATrendSignal.m except
% that it assigns  subConfig = portConfig.subStrat(fParam.subStrategyNum);

if nargin >= 6 && ~isempty(spliceDate)
   simStartDate = spliceDate; %#ok<NASGU>
else
   simStartDate = config.simStartDate;  %#ok<NASGU>
end 

if isfield(fParam,'nearZeroOption')
   nrZeroOpt = fParam.nearZeroOption; 
else
   nrZeroOpt = false;
end

data2 = startDataTrunc(data,config);

subStratConfig = portConfig.subStrat(fParam.subStrategyNum); 
% select subset of chosen asset class:
data.header = data.header(:,subStratConfig.indx);
data.close = data.close(:,subStratConfig.indx);
data.range = data.range(:,subStratConfig.indx);
data.values = data.values(:,subStratConfig.indx);
data.timezone = data.timezone(:,subStratConfig.indx);
data.startDates = data.startDates(:,subStratConfig.indx);
data.endDates = data.endDates(:,subStratConfig.indx);

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
t0 = find(data.dates== data2.dates(1)); 
signal.assetIDs = data.header; 
signal.dates = data.dates(t0:end,:); 
signal.values = signal1(t0:end,:); 
signal.assets = data.header; 
auxCalcs.assetIDs = data.header; 
auxCalcs.dates = data.dates(t0:end,:); 
auxCalcs.values = signalCube(t0:end,:,:); 
auxCalcs.lookbacks = fParam.a; 
auxCalcs.assets = data.header; 
% auxCalcs = signalCube; 
end % fn