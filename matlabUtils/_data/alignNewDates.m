function [outData, outIndex] = alignNewDates(inDates, inData, outDates)
% realign inData by business outDates; assumes chronological ordering
[nIns, nAssets] = size(inData);
if nargin < 3, outDates = makeDateSpan(inDates(1), inDates(nIns)); end
nOuts = length(outDates);
outData = nan(nOuts, nAssets);
outIndex = nan(size(outDates));
inCount = 1;
outCount = 1;
while inCount <= nIns && outCount <= nOuts
    k = 1;
    currOutDate = outDates(outCount);
    currInDate = inDates(inCount);
    if currOutDate == currInDate
        kMax = min(nOuts - outCount, nIns - inCount);
        while k<=kMax && outDates(outCount+k)==inDates(inCount+k), k=k+1; end
        outData(outCount:outCount+k-1,:) = inData(inCount:inCount+k-1,:);
        outIndex(outCount:outCount+k-1) = inCount:inCount+k-1;
        outCount = outCount + k;
        inCount = inCount + k;
    elseif currOutDate < currInDate
        kMax = nOuts - outCount;
        while k<=kMax && outDates(outCount+k) < currInDate, k = k + 1; end
        outCount = outCount + k;
    else   % currOutDate > currInDate
        kMax = nIns - inCount;
        while k<=kMax && currOutDate > inDates(inCount+k), k = k + 1; end
        inCount = inCount + k;
        outData(outCount,:) = inData(inCount-1,:);
        outIndex(outCount) = inCount-1;
    end % if currOutDate
end % while inCount