function signal = calcBrkOutTrendSignal(data,config,portConfig,fParam,spliceDate)

if nargin >= 5 && ~isempty(spliceDate)
   simStartDate = spliceDate;
else
   simStartDate = config.simStartDate; 
end 

if isfield(config,'trendSignalOption')
   signalOption = config.trendSignalOption; 
else
   signalOption = 1; 
end

if signalOption == 3
   [signal, ~] = calcBrkOutSigEnhanced(data,fParam,simStartDate); 
else
   [signal, ~] = calcBrkOutSig(data,fParam,simStartDate); 
end

% structure output variable: 
signal.assets = signal.assetIDs;
% signal.assetIDs = data.header; 
% signal.dates = signal.dates; 
% signal.values = signal.values; 

end % fn