function positionToday = adjustPositions(positionToday, positionYesterday, portConfig, simStruct)

if isfield(portConfig, 'subStratTradeThreshold')
    threshold = zeros(1, length(positionToday));
    for i = 1 : portConfig.numSubStrats
        threshold(1, simStruct.subStrat(i).indx) = ones(1, length(simStruct.subStrat(i).indx))* portConfig.subStratTradeThreshold(i);
    end
    replaceIndex = abs(positionToday - positionYesterday) < threshold;
    positionToday(replaceIndex) = positionYesterday(replaceIndex);
end
    
end