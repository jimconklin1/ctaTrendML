function dataStruct = fetchAlignedTsrpCcyMinBars ( tsrpCcyIds, startDate, endDate)

% This function fetches min bar data from TSRP for ccy and aligns
%  them according to the order of given tsrpCcyIds and the union of all available
%  dates.  

% Inputs: 
%   tsrpCcyIds = cell array of strings; TsrpID of ccy.
%   startDate = 'yyyy-mm-dd'.
%   endDate = 'yyyy-mm-dd'.
    
    

    if ~ischar(startDate)
       startDate = datestr(startDate,'yyyy-mm-dd'); 
    end 

    if ~ischar(endDate)
       endDate = datestr(endDate,'yyyy-mm-dd'); 
    end

    tsrpCcyIdsMinBars = tsrpCcyIds;
    % add '_1m' to NDFs tsrp ids (required ONLY for fetching minbars)
    for i =1 : length (tsrpCcyIdsMinBars)
        if  ismember(tsrpCcyIdsMinBars(i),{ 'fx.usdars', 'fx.usdbrl', 'fx.usdclp', 'fx.usdcny', 'fx.usdcop',  'fx.usdidr',...
                                            'fx.usdinr', 'fx.usdkrw', 'fx.usdmyr', 'fx.usdpen', 'fx.usdphp', 'fx.usdtwd',...
                                            'fx.usdvnd'})
            tsrpCcyIdsMinBars(i)= strcat(tsrpCcyIdsMinBars (i),'_1m') ;
        end 
    end 

    outData = tsrp.fetch_intraday_ohlc(tsrpCcyIdsMinBars, startDate, endDate);
    % outdata: 
    % column1: dates; for each asset, subsequent 5 columns are: 
    %           open, high, low, close, flagIntger
    dataStruct.header = tsrpCcyIds;
    dataStruct.dates = outData(:,1);
    for n = 1:length(tsrpCcyIds)
       i = 5*(n-1)+5;
       dataStruct.close(:,n) = outData(:,i); 
       dataStruct.range(:,n) = outData(:,i-2) - outData(:,i-1); 
    end % for n



end