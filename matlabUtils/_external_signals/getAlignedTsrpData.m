function dataStruct = getAlignedTsrpData(assetID, ccyIndex, dataType, periodID, timeZone, startDate, endDate )

% This function fetches data from the TSRP and aligns them accoding to the 
% order in input assetID as well as the union of all available dates.
% NOTE: It can fetch assetID including ccy and Futures assets. 

% Inputs: 
%   assetID = cell array of strings; TsrpID of FX, or Futures, or mixed.
%   ccyIndex= true-false array referring to ccy index in assetID.
%   dataType = 'prices'/'price'/'bar'/'bars' (the same) OR
%              'returns'/'rtns'/'return'/'rtn' (the same).
%   periodID = 'min'/'minute' (the same) OR 'daily'.
%   timeZone= 'lon'/'london'/'lndn' (the same) OR  'tokyo'/'tyo' (the same)
%             OR 'newyork'/'nyc'/'ny'. timezone used ONLY for 'daily'.
%   startDate = 'yyyy-mm-dd'.
%   endDate = 'yyyy-mm-dd'

if ~ischar(startDate)
    startDate = datestr(startDate,'yyyy-mm-dd');
end

if ~ischar(endDate)
    endDate = datestr(endDate,'yyyy-mm-dd');
end

if strcmpi(periodID,'daily')
    if isempty(timeZone)
        close = 'lon';
    elseif strcmpi(timeZone,'tokyo')||strcmpi(timeZone,'tyo')
        close = 'tyo';
    elseif strcmpi(timeZone,'london')||strcmpi(timeZone,'lon')||strcmpi(timeZone,'lndn')
        close = 'lon';
    elseif strcmpi(timeZone,'newyork')||strcmpi(timeZone,'ny')||strcmpi(timeZone,'nyc')
        close = 'nyc';
    end % if
end % if

if strcmpi(dataType,'prices') || strcmpi(dataType,'price') ...
        || strcmpi(dataType,'bar') || strcmpi(dataType,'bars')
    if strcmpi(periodID,'daily')
        outDataCcy = tsrp.fetch_raw_session_day_bar(assetID(ccyIndex), startDate, endDate, close);
        outDataFutures = tsrp.fetch_syn_session_day_bar(assetID(~ccyIndex), startDate, endDate, close);
        newDates = union(outDataCcy(:,1),outDataFutures(:,1),'sorted');
        [tempFut,~] = alignNewDatesJC(floor(outDataFutures(:,1)),outDataFutures(:,2:end),floor(newDates),NaN);
        [tempCcy,~] = alignNewDatesJC(floor(outDataCcy(:,1)),outDataCcy(:,2:end),floor(newDates),NaN);
        outData = [newDates,tempCcy,tempFut];
        % outdata:
        % column1: dates; for each asset, subsequent 5 columns are:
        %           open, high , low , price, flagIntger , flagIntger
        for n = 1:length(assetID)
            i = 6*(n-1)+5;
            dataStruct0.close(:,n) = outData(:,i);
            dataStruct0.range(:,n) = outData(:,i-2) - outData(:,i-1);
        end % for n
        newAssetID = [assetID(ccyIndex),assetID(~ccyIndex)];
    elseif strcmpi(periodID,'minute') || strcmpi(periodID,'minutes') || strcmpi(periodID,'min')
        if ~isempty(assetID(~ccyIndex)) &&  ~isempty(assetID(ccyIndex)) % if there are futures and ccys
            rawTsrpCcyMinPrices = fetchAlignedTsrpCcyMinBars( assetID(ccyIndex), startDate, endDate);
            rawTsrpFutureMinPrices= fetchAlignedTsrpFutureMinBars( assetID(~ccyIndex), startDate, endDate);
            newDates = union(rawTsrpCcyMinPrices.dates,rawTsrpFutureMinPrices.dates , 'sorted');
            ccyTempClose = aligneNewTimeStapms( rawTsrpCcyMinPrices.dates, rawTsrpCcyMinPrices.close , newDates    ) ;
            futureTempClose = aligneNewTimeStapms( rawTsrpFutureMinPrices.dates, rawTsrpFutureMinPrices.close , newDates    ) ;
            ccyTempRange  = aligneNewTimeStapms( rawTsrpCcyMinPrices.dates, rawTsrpCcyMinPrices.range , newDates    ) ;
            futureTempRange = aligneNewTimeStapms( rawTsrpFutureMinPrices.dates, rawTsrpFutureMinPrices.range , newDates    ) ;
            dataStruct0.close = [ccyTempClose,futureTempClose];
            dataStruct0.range = [ccyTempRange,futureTempRange];
            newAssetID = [rawTsrpCcyMinPrices.header, rawTsrpFutureMinPrices.header];
        elseif isempty(assetID(~ccyIndex)) &&  ~isempty(assetID(ccyIndex)) % if there are only ccys
            rawTsrpCcyMinPrices = fetchAlignedTsrpCcyMinBars( assetID(ccyIndex), startDate, endDate);
            dataStruct0.close = rawTsrpCcyMinPrices.close;
            dataStruct0.range = rawTsrpCcyMinPrices.range;
            newAssetID = rawTsrpCcyMinPrices.header;
            newDates =rawTsrpCcyMinPrices.dates;
        elseif ~isempty(assetID(~ccyIndex)) &&  isempty(assetID(ccyIndex)) % if there are only futures
            rawTsrpFutureMinPrices = fetchAlignedTsrpFutureMinBars( assetID(~ccyIndex), startDate, endDate);
            newDates = rawTsrpFutureMinPrices.dates;
            dataStruct0.close = rawTsrpFutureMinPrices.close ;
            dataStruct0.range = rawTsrpFutureMinPrices.range ;
            newAssetID = rawTsrpFutureMinPrices.header;
        end
    end
elseif  strcmpi(dataType,'returns') || strcmpi(dataType,'return') ||...
        strcmpi(dataType,'rtns') || strcmpi(dataType,'rtn')
    if strcmpi(periodID,'daily')
        outDataCcy = tsrp.fetch_raw_session_day_return(assetID(ccyIndex), startDate, endDate, close);
        outDataFutures = tsrp.fetch_syn_session_day_return(assetID(~ccyIndex), startDate, endDate, close);
        if isempty(outDataCcy)
            newDates = outDataFutures(:,1);
            newAssetID = assetID;
            outData = outDataFutures;
        elseif isempty(outDataFutures)
            newDates = outDataCcy(:,1);
            newAssetID = assetID;
            outData = outDataCcy;
        else
            newDates = union(outDataCcy(:,1),outDataFutures(:,1),'sorted');
            [tempFuture,~] = alignNewDatesJC(floor(outDataFutures(:,1)),outDataFutures(:,2:end),floor(newDates),NaN);
            [tempCcy,~] = alignNewDatesJC(floor(outDataCcy(:,1)),outDataCcy(:,2:end),floor(newDates),NaN);
            newAssetID = [assetID(ccyIndex),assetID(~ccyIndex)];
            outData = [newDates,tempCcy,tempFuture];
        end
        % outdata:
        % column1: dates; for each asset, subsequent 4 columns are:
        %           rtn, high/close-1, low/close-1, flagIntger
        for n = 1:length(assetID)
            i = 4*(n-1)+2;
            dataStruct0.close(:,n) = outData(:,i);
            dataStruct0.range(:,n) = outData(:,i+1) - outData(:,i+2);
        end % for n
        
    elseif strcmpi(periodID,'session') || strcmpi(periodID,'sessions')
        if ~isempty(assetID(~ccyIndex)) &&  ~isempty(assetID(ccyIndex))
            outDataCcy = tsrp.fetch_raw_session_return(assetID(ccyIndex), startDate, endDate);
            outDataFutures = tsrp.fetch_syn_session_return(assetID(~ccyIndex), startDate, endDate);
            ccyDates= outDataCcy(:,1);
            futuresDates = outDataFutures(:,1);
            [newDates ,~, newDatesIndex]   = unique([ccyDates; futuresDates], 'sorted');
            ccyDateIndex = newDatesIndex(1:length(ccyDates));
            futureDateIndex = newDatesIndex(length(ccyDates)+1:end);
            ccyAssetIDs= assetID(ccyIndex);
            futuresAssetIDs = assetID(~ccyIndex);
            ccyTempClose = nan(length(newDates),length (ccyAssetIDs)) ;
            futureTempClose = nan(length(newDates),length (futuresAssetIDs)) ;
            ccyTempRange = nan(length(newDates),length (ccyAssetIDs)) ;
            futureTempRange = nan(length(newDates),length (futuresAssetIDs)) ;
            for n = 1:length(ccyAssetIDs)
                i = 4*(n-1)+2;
                ccyTempClose (ccyDateIndex,n) = outDataCcy(:,i);
                ccyTempRange (ccyDateIndex,n)=outDataCcy(:,i+1) - outDataCcy(:,i+2);
            end % f
            for n = 1:length(futuresAssetIDs)
                i = 4*(n-1)+2;
                futureTempClose (futureDateIndex,n) = outDataFutures(:,i);
                futureTempRange (futureDateIndex,n)=outDataFutures(:,i+1) - outDataFutures(:,i+2);
            end % f
            dataStruct0.close  = [ccyTempClose,futureTempClose];
            dataStruct0.range  = [ccyTempRange,futureTempRange];
            newAssetID = [ccyAssetIDs, futuresAssetIDs];
        elseif ~isempty(assetID(~ccyIndex)) &&  isempty(assetID(ccyIndex))
            outDataFutures = tsrp.fetch_syn_session_return(assetID(~ccyIndex), startDate, endDate);
            newDates = outDataFutures(:,1);
            newAssetID = assetID(~ccyIndex);
            for n = 1:length(newAssetID)
                i = 4*(n-1)+2;
                dataStruct0.close (:,n) = outDataFutures(:,i);
                dataStruct0.range (:,n)=outDataFutures(:,i+1) - outDataFutures(:,i+2);
            end % for
        end % if
    end % if
end % if
dataStruct.header = assetID;
dataStruct.dates= newDates ;
dataStruct.close= nan (length(newDates),length(assetID)) ;
dataStruct.range= nan (length(newDates),length(assetID)) ;
[~,i_assetID,i_newAssetID] = intersect(assetID,newAssetID,'stable');
dataStruct.close (:,i_assetID)= dataStruct0.close (:,i_newAssetID);
dataStruct.range (:,i_assetID)= dataStruct0.range (:,i_newAssetID);
end % fn