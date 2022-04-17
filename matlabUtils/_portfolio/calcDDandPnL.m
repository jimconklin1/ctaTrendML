function simStruct = calcDDandPnL(simStruct,portConfig,dataConfig,rtns,t,k,ddMode)
if nargin < 7 || isempty(k)
   ddMode = true; 
end

if nargin < 6 || isempty(k)
   k = 0; 
end 

if k~=0
   executionLag = portConfig.subStrat(k).executionLag; 
   if executionLag==0
      tradingWts = simStruct.wts; 
   elseif executionLag==1
      tradingWts = [zeros(size(simStruct.wts(1,:))); simStruct.wts(1:end-1,:)]; 
   elseif executionLag==2
      tradingWts = [zeros(size(simStruct.wts(1:2,:))); simStruct.wts(1:end-2,:)]; 
   end % if
   ddConfig = portConfig.subStrat(k);
else 
   tradingWts = simStruct.wts; 
   ddConfig = portConfig; 
end 

linearTC = dataConfig.assetTCs(simStruct.indx); 
simStruct.tc(t,:) = 0.5*abs(tradingWts(t,:)-tradingWts(t-1,:)).*linearTC/10000;
tempRtns = rtns(t,:); 
tempRtns(isnan(tempRtns)) = 0; 
simStruct.pnl(t,:) = tempRtns.*tradingWts(t-1,:) - simStruct.tc(t,:); 
simStruct.totPnl(t,:) = sum(simStruct.pnl(t,:),2);

% update decayed drawdown:
if ddMode
    simStruct.dd.nav(t) =  (1+simStruct.totPnl(t))*simStruct.dd.nav(t-1);
    if simStruct.dd.nav(t) >= simStruct.dd.highValue(t-1)
        simStruct.dd.highDate(t) = simStruct.dates(t);
        simStruct.dd.highValue(t) = simStruct.dd.nav(t);
    else
        simStruct.dd.highDate(t) = simStruct.dd.highDate(t-1);
        simStruct.dd.highValue(t) = simStruct.dd.highValue(t-1);
    end % if
    tempDecayedHigh = simStruct.dd.decayedHigh(t-1)*exp(-ddConfig.ddDecayRate/252);
    if simStruct.dd.nav(t) >= tempDecayedHigh
        simStruct.dd.decayedHigh(t) = simStruct.dd.nav(t);
    else
        simStruct.dd.decayedHigh(t) = tempDecayedHigh;
    end % if
    simStruct.dd.drawdown(t) = 1-simStruct.dd.nav(t)/simStruct.dd.highValue(t);
    simStruct.dd.decayedDrawdown(t) = 1-simStruct.dd.nav(t)/simStruct.dd.decayedHigh(t);
end % if ddMode 
end % fn 

% for k = 1:length(simStruct.subStrat)
%     simStruct.subStrat(k).pnl(t,:) = rtns(t,simStruct.subStrat(k).indx).*simStruct.subStrat(k).wts(t-1,:);
%     simStruct.subStrat(k).totPnl(t,:) = rtns(t,simStruct.subStrat(k).indx)*simStruct.subStrat(k).wts(t-1,:)';
%     % update decayed drawdown:
%     simStruct.subStrat(k).dd.nav(t) = (1+simStruct.subStrat(k).totPnl(t))*simStruct.subStrat(k).dd.nav(t-1);
%     if simStruct.subStrat(k).dd.nav(t) >= simStruct.subStrat(k).dd.highValue(t-1)
%         simStruct.subStrat(k).dd.highDate(t) = simStruct.dates(t);
%         simStruct.subStrat(k).dd.highValue(t) = simStruct.subStrat(k).dd.nav(t);
%     else
%         simStruct.subStrat(k).dd.highDate(t) = simStruct.subStrat(k).dd.highDate(t-1);
%         simStruct.subStrat(k).dd.highValue(t) = simStruct.subStrat(k).dd.highValue(t-1);
%     end % if
%     tempDecayedHigh = simStruct.subStrat(k).dd.decayedHigh(t-1)*exp(-portConfig.subStrat(k).ddDecayRate/252);
%     if simStruct.subStrat(k).dd.nav(t) >= tempDecayedHigh
%         simStruct.subStrat(k).dd.decayedHigh(t) = simStruct.subStrat(k).dd.nav(t);
%     else
%         simStruct.subStrat(k).dd.decayedHigh(t) = tempDecayedHigh;
%     end % if
%     simStruct.subStrat(k).dd.drawdown(t) = 1-simStruct.subStrat(k).dd.nav(t)/simStruct.subStrat(k).dd.highValue(t);
%     simStruct.subStrat(k).dd.decayedDrawdown(t) = 1-simStruct.subStrat(k).dd.nav(t)/simStruct.subStrat(k).dd.decayedHigh(t);
% end % for k