function portSim = constructPortfolio(dataStruct,riskWts,annPortVol,omega,method)
portSim.dates = dataStruct.dates; 
rtns = dataStruct.close;
[T,N] = size(rtns); 
wts = zeros(T,N); 
if size(riskWts,1) == 1
   riskWts = repmat(riskWts,[T,1]);
end % if
switch method 
   case 'riskParity'
      for t = 1:T 
         sig = squeeze(omega(:,:,t));  
         volVec = diag(sig).^0.5; 
         tempWts = riskWts(t,:)./volVec';
         tempWts(isnan(tempWts)) = 0; 
         adjCoeff = annPortVol(t)/(sqrt(260)*sqrt(tempWts*sig*tempWts')); 
         wts(t,:) = adjCoeff*tempWts;
      end % for
   case 'ERC'
      % not yet completed 
      wts = NaN; 
end % switch 

% compute PnL: 
pnl = zeros(size(wts)); 
pnl(2:end,:) = wts(1:end-1,:).*rtns(2:end,:); 
tc = zeros(size(wts)); 
tc(2:end,:) = -abs(wts(2:end,:)-wts(1:end-1,:)).*repmat(dataStruct.TC,[T-1,1])/10000; % TCs in bps
portSim.riskWts = riskWts; 
portSim.wts = wts; 
portSim.pnl = pnl; 
portSim.tc = tc; 
portSim.netPnl = pnl + tc; 
end % fn 