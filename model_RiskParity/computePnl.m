function portPnl = computePnl(dataStruct, portSim)

[T, ~] = size(dataStruct.close);

pnl = zeros(size(portSim.wts)); 
pnl(2:end,:) = portSim.wts(1:end-1,:).*dataStruct.close(2:end,:); 
tc = zeros(size(portSim.wts)); 
tc(2:end,:) = -abs(portSim.wts(2:end,:)-portSim.wts(1:end-1,:)).*repmat(dataStruct.TC,[T-1,1])/10000; % TCs in bps

portPnl.dates = dataStruct.dates;
portPnl.pnl = pnl; 
portPnl.tc = tc; 
portPnl.netPnl = pnl + tc; 

end