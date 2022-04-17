function dataStruct = fetchAlignedTSRPdata(assetID,dataType,periodID,timeZone,startDate,endDate,fxFlag,rtnType)

% Note: if fxFlag == 1, the routine forces the use of raw returns (syn rtns
%   do note exist for fx)

if nargin < 8 || isempty(rtnType) 
   rtnType = repmat({'syn'},[1,size(assetID,2)]); % 'syn' or 'raw'
end 

if nargin < 7 || isempty(fxFlag)
   fxFlag = false;
end 

if ~ischar(startDate)
   startDate = datestr(startDate,'yyyy-mmm-dd'); 
end 

if ~ischar(endDate)
   endDate = datestr(endDate,'yyyy-mmm-dd'); 
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

if strcmpi(dataType,'returns') || strcmpi(dataType,'return') || ...
   strcmpi(dataType,'rtns') || strcmpi(dataType,'rtn')
   if strcmpi(periodID,'daily')
      if fxFlag 
         outData = tsrp.fetch_raw_session_day_return(assetID, startDate, endDate, close);
      else
         indxR = find(strcmpi(rtnType,'raw')); 
         indxS = find(strcmpi(rtnType,'syn')); 
         if ~isempty(indxR) && ~isempty(indxS)
            outDataR = tsrp.fetch_syn_session_day_return(assetID(indxR), startDate, endDate, close);
            outDataS = tsrp.fetch_syn_session_day_return(assetID(indxS), startDate, endDate, close);
            newDates = union(outDataR(:,1),outDataS(:,1),'sorted');
            [tempS,~] = alignNewDatesJC(floor(outDataS(:,1)),outDataS(:,2:end),floor(newDates),NaN);
            [tempR,~] = alignNewDatesJC(floor(outDataR(:,1)),outDataR(:,2:end),floor(newDates),NaN);
            newAssetID = [assetID(indxR),assetID(indxS)];
            outData = [newDates,tempR,tempS];
         elseif isempty(indxR) && ~isempty(indxS)
            outData = tsrp.fetch_syn_session_day_return(assetID, startDate, endDate, close);
         else 
            outData = tsrp.fetch_raw_session_day_return(assetID, startDate, endDate, close);
         end 
      end 
   elseif strcmpi(periodID,'session') 
      if fxFlag 
         outData = tsrp.fetch_raw_session_return(assetID, startDate, endDate);
      else
         outData = tsrp.fetch_syn_session_return(assetID, startDate, endDate);
      end 
   end % if
elseif strcmpi(dataType,'price') || strcmpi(dataType,'prc') || ...
   strcmpi(dataType,'prcs') || strcmpi(dataType,'px')
   if strcmpi(periodID,'daily')
      if fxFlag 
         outData = tsrp.fetch_raw_session_day_bar(assetID, startDate, endDate, close);
      else
         indxR = find(strcmpi(rtnType,'raw')); 
         indxS = find(strcmpi(rtnType,'syn')); 
         if ~isempty(indxR) && ~isempty(indxS)
            outDataR = tsrp.fetch_raw_session_day_bar(assetID(indxR), startDate, endDate, close);
            outDataS = tsrp.fetch_syn_session_day_bar(assetID(indxS), startDate, endDate, close);
            newDates = union(outDataR(:,1),outDataS(:,1),'sorted');
            [tempS,~] = alignNewDatesJC(floor(outDataS(:,1)),outDataS(:,2:end),floor(newDates),NaN);
            [tempR,~] = alignNewDatesJC(floor(outDataR(:,1)),outDataR(:,2:end),floor(newDates),NaN);
            newAssetID = [assetID(indxR),assetID(indxS)];
            outData = [newDates,tempR,tempS];
         elseif isempty(indxR) && ~isempty(indxS)
            outData = tsrp.fetch_syn_session_day_bar(assetID, startDate, endDate, close);
         else 
            outData = tsrp.fetch_raw_session_day_bar(assetID, startDate, endDate, close);
         end 
      end 
   elseif strcmpi(periodID,'session') 
      if fxFlag 
         outData = tsrp.fetch_raw_session_bar(assetID, startDate, endDate);
      else
         outData = tsrp.fetch_syn_session_bar(assetID, startDate, endDate);
      end 
   end % if
end % if 

if isempty(outData)
    disp(['PROBLEM: found no data in data call between dates ',startDate,' and ',endDate,'.'])
    dataStruct = NaN;
    return
end 
% outdata: 
if strcmpi(dataType,'returns') || strcmpi(dataType,'return') || ...
   strcmpi(dataType,'rtns') || strcmpi(dataType,'rtn')
   % column1: dates; for each asset, subsequent 4 columns are: 
   %           rtn, high/close-1, low/close-1, flagIntger
   dataStruct.header = assetID;
   dataStruct.dates = outData(:,1); 
   for n = 1:length(assetID)
      i = 4*(n-1)+2;
      dataStruct.close(:,n) = outData(:,i); 
      dataStruct.range(:,n) = outData(:,i+1) - outData(:,i+2); 
   end % for n
   if exist('newAssetID','var')
      indx = mapStrings(assetID,newAssetID);
      dataStruct.close = dataStruct.close(:,indx);
      dataStruct.range = dataStruct.range(:,indx);
   end 
elseif strcmpi(dataType,'price') || strcmpi(dataType,'prc') || ...
   strcmpi(dataType,'prcs') || strcmpi(dataType,'px')
   % column1: dates; for each asset, subsequent 6 columns are: 
   %           open, high, low, close, (volume?), flagIntger
   dataStruct.header = assetID;
   dataStruct.dates = outData(:,1); 
   for n = 1:length(assetID)
      i = 6*(n-1)+2;
      dataStruct.open(:,n) = outData(:,i); 
      dataStruct.high(:,n) = outData(:,i+1); 
      dataStruct.low(:,n) = outData(:,i+2); 
      dataStruct.close(:,n) = outData(:,i+3); 
      dataStruct.range(:,n) = outData(:,i+1) - outData(:,i+2); 
   end % for n
   if exist('newAssetID','var')
      indx = mapStrings(assetID,newAssetID);
      dataStruct.open = dataStruct.open(:,indx);
      dataStruct.high = dataStruct.high(:,indx);
      dataStruct.low = dataStruct.low(:,indx);
      dataStruct.close = dataStruct.close(:,indx);
      dataStruct.range = dataStruct.range(:,indx);
   end 
end % if
end % fn