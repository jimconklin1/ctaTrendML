function [outData, outIndex] = alignNewDatesJC2(inDates, inData, outDates, fillVal, isRtns)
% Work in progress: trying to make this handle case of returns (and
%    cumulate, not skip returns)
% realign inData by business outDates; assumes chronological ordering
[nIns, nAssets] = size(inData);
if nargin < 5 || isempty(isRtns), isRtns = false; end 
if nargin < 4, fillVal = []; end 
if nargin < 3, outDates = makeDateSpan(inDates(1), inDates(nIns)); end
nOuts = length(outDates);
if ~isempty(fillVal)
    outData = repmat(fillVal,[nOuts, nAssets]);
else
    outData = nan(nOuts, nAssets);
end
outIndex = nan(size(outDates));
inCount = 1;
outCount = 1;
while inCount <= nIns && outCount <= nOuts
    k = 1;
    currOutDate = floor(outDates(outCount));
    currInDate = floor(inDates(inCount));
    if currOutDate == currInDate
        kMax = min(nOuts - outCount, nIns - inCount);
        while k<=kMax && floor(outDates(outCount+k)) == floor(inDates(inCount+k)), k=k+1; end
        outData(outCount:outCount+k-1,:) = inData(inCount:inCount+k-1,:);
        outIndex(outCount:outCount+k-1) = inCount:inCount+k-1;
        outCount = outCount + k;
        inCount = inCount + k;
    elseif currOutDate < currInDate
        kMax = nOuts - outCount;
        cumulator = zeros(1,size(inData,2));
        while k<=kMax && floor(outDates(outCount+k)) < currInDate 
            k = k + 1; 
            if isRtns
               cumulator = nansum([cumulator; inData(inCount+k-1,:)]);
            end 
        end
        outCount = outCount + k;
    elseif ~isempty(fillVal)
        kMax = nIns - inCount;
        while k<=kMax && currOutDate > floor(inDates(inCount+k)), k = k + 1; end
        inCount = inCount + k;
        outData(outCount,:) = repmat(fillVal,[1, size(inData,2)]); 
        outIndex(outCount) = inCount-1;
    else   % currOutDate > currInDate
        kMax = nIns - inCount;
        while k<=kMax && currOutDate > floor(inDates(inCount+k)), k = k + 1; end
        inCount = inCount + k;
        outData(outCount,:) = inData(inCount-1,:);
        outIndex(outCount) = inCount-1;
    end % if currOutDate
end % while inCount