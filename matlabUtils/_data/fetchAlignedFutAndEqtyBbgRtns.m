function rtnData = fetchAlignedFutAndEqtyBbgRtns(header,startDate,endDate,ctx)

% make header a row vector
if size(header,1) > size(header,2)
   header = header';
end 
eqIndx = [];
futIndx = [];
for n = 1:length(header)
   if strcmpi(header{1,n}(1,end-5:end),'equity')
      eqIndx = [eqIndx,n]; %#ok
   else
      futIndx = [futIndx,n]; %#ok
   end
end % for
if ~isempty(eqIndx)
   [badTickers,eqData] = fetchBbgEquityRtnsJC(header(eqIndx),startDate,endDate,ctx.bbgConn,'daily'); %#ok
else
    eqData = [];
end % end if
if ~isempty(futIndx)
[badTickers,futData] = fetchBbgRtnsJC2(header(futIndx),startDate,endDate,ctx.bbgConn,'daily'); %#ok
else
    futData = [];
end % end if
% endDateStr = datestr(endDate,'yyyy-mmm-dd');
% startDateStr = datestr(startDate,'yyyy-mmm-dd');% futData = fetchAlignedTSRPdata(header(futIndx),'returns','daily','london',startDate,endDate,false,'syn'); 
% align data:
rtnData.header = header;
if isempty(eqIndx) 
   outDates = unique(floor(futData.dates)); 
   [tempDataFut, outIndex] = alignNewDatesJC2(futData.dates, futData.rtns, outDates, [], true); %#ok
   rtnData.dates = outDates;
   rtnData.close = zeros(size(rtnData.dates,1),size(rtnData.header,2));
   rtnData.close = tempDataFut;
elseif isempty(futIndx)
   outDates = unique(floor(eqData.dates)); 
   [tempDataEq, outIndex] = alignNewDatesJC2(eqData.dates, eqData.rtns, outDates, [], true); %#ok
   rtnData.dates = outDates;
   rtnData.close = zeros(size(rtnData.dates,1),size(rtnData.header,2));
   rtnData.close = tempDataEq;
else
   outDates = unique(union(floor(eqData.dates),floor(futData.dates))); 
   [tempDataEq, outIndex] = alignNewDatesJC2(eqData.dates, eqData.rtns, outDates, [], true); %#ok
   [tempDataFut, outIndex] = alignNewDatesJC2(futData.dates, futData.rtns, outDates, [], true); %#ok
   rtnData.dates = outDates;
   rtnData.close = zeros(size(rtnData.dates,1),size(rtnData.header,2));
   rtnData.close(:,eqIndx) = tempDataEq;
   rtnData.close(:,futIndx) = tempDataFut;
end

end