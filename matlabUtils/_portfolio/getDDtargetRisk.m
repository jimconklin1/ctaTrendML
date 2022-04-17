function targetRisk = getDDtargetRisk(simStruct,portConfig,k,t) 
% get the target risk for a given trade date due to the drawdown 
% target risk is in monthly unit, i.e. 0.039 means we want to take a mnthly
% risk of 3.9%. 
% idx = obj.dateIdx(tradeDate); 
tt = max(t-1,1); 
if k == 0 % the case is the main program
   if portConfig.drawDownControl
      u = 1 - simStruct.dd.decayedDrawdown(tt); 
      ddcParam = [portConfig.DDriskAvers portConfig.DDalpha ...
                  portConfig.ddDecayRate portConfig.DDsharpe 1.0]; 
      currScale = ddScale(ddcParam, u); 
      targetRisk = currScale/ddcParam(1)*ddcParam(4)/sqrt(12); 
      if (targetRisk > portConfig.maxRisk); 
        targetRisk = portConfig.maxRisk; 
      end 
      if (targetRisk < portConfig.DDminRisk); 
        targetRisk = portConfig.DDminRisk; 
      end 
   else 
      targetRisk = portConfig.maxRisk; 
   end % if drawDownControl 
else % the case is the subStrategy
   if portConfig.subStrat(k).ddOpt
      u = 1 - simStruct.dd.decayedDrawdown(tt); 
      ddcParam = [portConfig.subStrat(k).DDriskAvers portConfig.subStrat(k).DDalpha ...
                  portConfig.subStrat(k).ddDecayRate portConfig.subStrat(k).DDsharpe 1.0]; 
      currScale = ddScale(ddcParam, u); 
      targetRisk = currScale/ddcParam(1)*ddcParam(4)/sqrt(12); 
      if (targetRisk > portConfig.subStrat(k).maxRisk); 
        targetRisk = portConfig.subStrat(k).maxRisk; 
      end 
      if (targetRisk < portConfig.subStrat(k).DDminRisk); 
        targetRisk = portConfig.subStrat(k).DDminRisk; 
      end 
   else 
      if ~isnan(portConfig.subStrat(k).maxRisk)
         targetRisk = portConfig.subStrat(k).maxRisk; 
      else
          targetRisk = portConfig.maxRisk;
      end 
   end % if drawDownControl
end % if k == 0

end % fn 
