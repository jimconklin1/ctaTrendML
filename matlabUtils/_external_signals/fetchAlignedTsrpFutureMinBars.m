function outStruct = fetchAlignedTsrpFutureMinBars(futureTsrpIDs,  startDate, endDate)
   
if ~ischar(startDate)
    startDate = datestr(startDate,'yyyy-mm-dd');
end

if ~ischar(endDate)
    endDate = datestr(endDate,'yyyy-mm-dd');
end

data = tsrp.build_rolled_intraday_ohlc(futureTsrpIDs, startDate, endDate, -3);
outStruct.header = futureTsrpIDs;
outStruct.dates = data(:, 1);
outStruct.close = data(:, (1:floor(size(data, 2)/5))*5);
outStruct.range = data(:, (1:floor(size(data, 2)/5))*5 - 1) - data(:, (1:floor(size(data, 2)/5))*5 - 2);

end % fn
