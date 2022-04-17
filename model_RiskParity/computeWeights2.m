function portSim = computeWeights2(dataStruct,riskWts,annPortVol,omega)

portSim.dates = dataStruct.dates; 
rtns = dataStruct.close;
[T,N] = size(rtns); 
wts = zeros(T,N); 
if size(riskWts,1) == 1
   riskWts = repmat(riskWts,[T,1]);
end
holidayStruct.header = dataStruct.header; 
holidayStruct.holidays = dataStruct.holidays;
rebalTol = 0.0001;

wts0 = zeros(1,N);
dates0 = portSim.dates(1,:)-1; 
for t = 1:T 
   sig = squeeze(omega(:,:,t));  
   volVec = diag(sig).^0.5; 
   tempWts = riskWts(t,:)./volVec';
   tempWts(isnan(tempWts)) = 0; 
   adjCoeff = annPortVol(t)/(sqrt(260)*sqrt(tempWts*sig*tempWts')); 
   temp = [wts0; adjCoeff*tempWts];
   tDates = [dates0; portSim.dates(t,:)];
   temp = getAllowableTrades(temp, annPortVol(t,:), rebalTol, tDates, holidayStruct); 
   wts0 = temp(2,:);
   dates0 = tDates(2,:); 
   wts(t,:) = temp(2,:);
end

portSim.riskWts = riskWts; 
portSim.wts = wts;
end