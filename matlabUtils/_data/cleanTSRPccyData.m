function ccyData = cleanTSRPccyData(ccyData,config,timeZone,bbgConn)
if strcmpi(timeZone,'TK')||strcmpi(timeZone,'tokyo')||strcmpi(timeZone,'asia')||strcmpi(timeZone,'japan')
   timeZone = 'Tokyo';
elseif strcmpi(timeZone,'NY')||strcmpi(timeZone,'NYC')||strcmpi(timeZone,'newyork')||strcmpi(timeZone,'americas')||strcmpi(timeZone,'us')
   timeZone = 'NY';
else
   timeZone = 'London'; 
end % if 

cleanList = {'fx.usdidr','fx.usdinr','fx.usdkrw','fx.usdmyr','fx.usdphp', ...
             'fx.usdtwd','fx.usdrub','fx.usdbrl','fx.usdclp','fx.usdcop'}; 
bbgIDs = {'IHN+1M','IRN+1M','KWN+1M','MRN+1M','PPN+1M',...
          'NTN+1M','RUB+1M','BRL','CHN+1M','CLN+1M'};
bbgFwdsIDs = {'IHN+1M BGNL Curncy','IHN+2M BGNL Curncy','IRN+1M BGNL Curncy','IRN+2M BGNL Curncy',...
              'KWN+1M BGNL Curncy','KWN+2M BGNL Curncy',...
              'MRN+1M BGNL Curncy','MRN+2M BGNL Curncy','PPN+1M BGNL Curncy','PPN+2M BGNL Curncy',...
              'NTN+1M BGNL Curncy','NTN+2M BGNL Curncy','RUB+1M BGNL Curncy','RUB+2M BGNL Curncy',...
              'CHN+1M BGNL Curncy','CHN+2M BGNL Curncy','CLN+1M BGNL Curncy','CLN+2M BGNL Curncy'};
bbgFields = repmat({'PX_LAST'},[1,length(bbgIDs)]); 
bbgFwdsFlds = repmat({'PX_LAST'},[1,length(bbgFwdsIDs)]); 

% identify currencies that require cleaning:
[indx,~] = ismember(ccyData.header,cleanList);
indx = find(indx); % where those tickers are in ccyData.header
tsrpIDs = ccyData.header(indx); 
indx2 = mapStrings(tsrpIDs,cleanList); % where the tickers are in cleanList and bbgIDs
bbgIDs = bbgIDs(indx2); %  aligning bbyIDs with tsprIDs.
switch timeZone
    case 'Tokyo'
        % create bbg tickers:
        longBbgIDs = bbgIDs; 
        for i = 1:length(bbgIDs)
            longBbgIDs(i) = {[bbgIDs{i},' CMPT Curncy']};
        end % for
        
        % get bbg flat px data and compute %-age changes:
%         temp1 = tsrp.fetch_bbg_daily_close(bbgIDs, config.startDate, config.endDate); 
%         [tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end)); 
        bbgData = fetchBbgDataJC(longBbgIDs,bbgFields,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        bbgFwdsData = fetchBbgDataJC(bbgFwdsIDs,bbgFwdsFlds,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        temp2 = transformFlatData(bbgData.header',bbgData.dates,bbgData.levels,ones(1,length(longBbgIDs))); 
        bbgData.values = temp2;

        % particular fixes:
        nn = find(strcmpi(ccyData.header,'fx.usdils'),1);
        if ~isempty(nn)
           tt = find(ccyData.dates == datenum('20-Jun-2000 06:00:00'));
           ccyData.close(tt,nn) = 4.1024/4.0859-1; %#ok<FNDSB> 
        end
        
        nn = find(strcmpi(ccyData.header,'fx.usdidr'),1);
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('31-Oct-2008 06:00:00'));
            ccyData.close(tt,nn) = 10975/10700-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2012 06:00:00'));
            ccyData.close(tt,nn) = 9634/9644-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Oct-2015 06:00:00'));
            ccyData.close(tt,nn) = 13619/13480-1; %#ok<FNDSB>
        end
        
        nn = find(strcmpi(ccyData.header,'fx.usdkrw'));
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('01-Dec-2010 06:00:00'));
            ccyData.close(tt,nn) = 1146.00/1160.5 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2012 06:00:00'));
            ccyData.close(tt,nn) = 1084.35/1089.25 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2013 06:00:00'));
            ccyData.close(tt,nn) = 1060.41/1063.37-1; %#ok<FNDSB>
        end % if
        
        % now clean TSRP data: 
        % determine a threshold for "bad data":
        t0 = max([size(bbgData.values,1)-2080,1]); 
        threshold = 1.2*max(abs(bbgData.values(t0:end,:)));
        for i = 1:length(tsrpIDs)
           if strcmpi(tsrpIDs(i),'fx.usdtwd')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'NTN+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'NTN+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           elseif strcmpi(tsrpIDs(i),'fx.usdrub')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'RUB+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'RUB+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           else 
               ii = indx(i);
               tIndx = find(abs(ccyData.close(:,ii))>threshold(i));
               for j = 1:length(tIndx)
                   dd = ccyData.dates(tIndx(j));
                   t = find(bbgData.dates<=dd,1,'last');
                   if ~isempty(t)
                       ccyData.close(tIndx(j),ii) = bbgData.values(t,i);
                   else
                       ccyData.close(tIndx(j),ii) = NaN;
                   end % if
               end % for j
           end % if
        end % for i
    case 'London'
        % create bbg tickers:
        longBbgIDs = bbgIDs; 
        for i = 1:length(bbgIDs)
            longBbgIDs(i) = {[bbgIDs{i},' CMPL Curncy']};
        end % for
        
        % get bbg flat px data and compute %-age changes:
%         temp1 = tsrp.fetch_bbg_daily_close(bbgIDs, config.startDate, config.endDate); 
%         [tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end)); 
        bbgFields = repmat({'PX_LAST'},[1,length(longBbgIDs)]); 
        bbgData = fetchBbgDataJC(longBbgIDs,bbgFields,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        bbgFwdsData = fetchBbgDataJC(bbgFwdsIDs,bbgFwdsFlds,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        temp2 = transformFlatData(bbgData.header',bbgData.dates,bbgData.levels,ones(1,length(longBbgIDs))); 
        bbgData.values = temp2;
        
        % determine a threshold for "bad data":
        t0 = max([size(bbgData.values,1)-2080,1]); 
        threshold = 1.2*max(abs(bbgData.values(t0:end,:)));
        
        % particular fixes:
        nn = find(strcmpi(ccyData.header,'fx.usdils'),1);
        if ~isempty(nn)
           tt = find(ccyData.dates == datenum('20-Jun-2000 15:00:00'));
           ccyData.close(tt,nn) = 4.1024/4.0859-1; %#ok<FNDSB> 
        end
        
        nn = find(strcmpi(ccyData.header,'fx.usdkrw'));
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('29-Nov-2010 16:00:00'));
            ccyData.close(tt,nn) = -0.0062; %#ok<FNDSB>
        end
        
        nn = find(strcmpi(ccyData.header,'fx.usdbrl'));
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('28-Oct-1999 15:00:00'));
            ccyData.close(tt,nn) = 1.9735/1.9980-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('30-Oct-2001 16:00:00'));
            ccyData.close(tt,nn) = 1.7220/1.7235-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('30-Oct-2003 16:00:00'));
            ccyData.close(tt,nn) = 2.8493/2.845-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('28-Oct-2004 15:00:00'));
            ccyData.close(tt,nn) = 2.6830/2.8585-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2005 16:00:00'));
            ccyData.close(tt,nn) = 2.1817/2.2018-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('27-Nov-2008 16:00:00'));
            ccyData.close(tt,nn) = 2.2815/2.2680-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2011 16:00:00'));
            ccyData.close(tt,nn) = 1.8454/1.8548-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('28-Nov-2013 16:00:00'));
            ccyData.close(tt,nn) = 2.3176/2.3305-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('27-Nov-2014 16:00:00'));
            ccyData.close(tt,nn) = 2.5311/2.5015-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('27-Nov-2015 16:00:00'));
            ccyData.close(tt,nn) = 3.8466/3.7435-1; %#ok<FNDSB>
        end
        
        if ~isempty(nn)
            nn = find(strcmpi(ccyData.header,'fx.usdclp'));
            tt = find(ccyData.dates == datenum('04-Jan-2011 16:00:00'));
            ccyData.close(tt,nn) = 488.6/466.75-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2011 16:00:00'));
            ccyData.close(tt,nn) = 526.75/524.85-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('30-Oct-2012 16:00:00'));
            ccyData.close(tt,nn) = 481.6/484.15-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2012 16:00:00'));
            ccyData.close(tt,nn) = 481.45/482.69-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('27-Nov-2014 16:00:00'));
            ccyData.close(tt,nn) = 601.80/600.94-1; %#ok<FNDSB>
        end
        
        if ~isempty(nn)
            nn = find(strcmpi(ccyData.header,'fx.usdcop'));
            tt = find(ccyData.dates == datenum('29-Nov-2012 16:00:00'));
            ccyData.close(tt,nn) = 1821.91/1830.35-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('28-Nov-2014 16:00:00'));
            ccyData.close(tt,nn) = 2224.5/2170.5-1; %#ok<FNDSB>
        end
        
        % now clean TSRP data:
        for i = 1:length(tsrpIDs)
            if strcmpi(tsrpIDs(i),'fx.usdmyr') 
                ii = indx(i); 
                i1 = find(strcmpi(bbgFwdsData.header,'MRN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'MRN+2M BGNL Curncy')); 
                ptsRoll = (1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
            elseif strcmpi(tsrpIDs(i),'fx.usdtwd')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'NTN+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'NTN+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           elseif strcmpi(tsrpIDs(i),'fx.usdrub')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'RUB+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'RUB+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           else 
               ii = indx(i);
               tIndx = find(abs(ccyData.close(:,ii))>threshold(i));
               for j = 1:length(tIndx)
                   dd = ccyData.dates(tIndx(j));
                   t = find(bbgData.dates<=dd,1,'last');
                   if ~isempty(t)
                       ccyData.close(tIndx(j),ii) = bbgData.values(t,i);
                   else
                       ccyData.close(tIndx(j),ii) = NaN;
                   end % if
               end % for j
           end % if
        end % for i
    case 'NY'
        % create bbg tickers:
        longBbgIDs = bbgIDs; 
        for i = 1:length(bbgIDs)
            longBbgIDs(i) = {[bbgIDs{i},' CMPN Curncy']};
        end % for
        
        % get bbg flat px data and compute %-age changes:
%         temp1 = tsrp.fetch_bbg_daily_close(bbgIDs, config.startDate, config.endDate); 
%         [tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end)); 
        bbgFields = repmat({'PX_LAST'},[1,length(longBbgIDs)]); 
        bbgData = fetchBbgDataJC(longBbgIDs,bbgFields,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        bbgFwdsData = fetchBbgDataJC(bbgFwdsIDs,bbgFwdsFlds,bbgConn,config.dataStartDate,config.simEndDate,'daily');
        temp2 = transformFlatData(bbgData.header',bbgData.dates,bbgData.levels,ones(1,length(longBbgIDs))); 
        bbgData.values = temp2;
        
        % determine a threshold for "bad data":
        t0 = max([size(bbgData.values,1)-2080,1]); 
        threshold = 1.2*max(abs(bbgData.values(t0:end,:))); 
        
        % particular fixes:
        nn = find(strcmpi(ccyData.header,'fx.usdils'),1);
        if ~isempty(nn)
           tt = find(ccyData.dates == datenum('20-Jun-2000 20:00:00'));
           ccyData.close(tt,nn) = 4.1024/4.0859-1; %#ok<FNDSB> 
        end 
        
        nn = find(strcmpi(ccyData.header,'fx.usdkrw'),1);
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('03-Nov-2010 20:00:00'));
            ccyData.close(tt,nn) = 1107.24/1113.45 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('20-Jun-2013 20:00:00'));
            ccyData.close(tt,nn) = 1156.2/1142.2 - 1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('01-Dec-2014 21:00:00'));
            ccyData.close(tt,nn) = 1111.85/1114.60 -1; %#ok<FNDSB>
        end
        
        nn = find(strcmpi(ccyData.header,'fx.usdthb'),1);
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('30-Oct-2003 21:00:00')); 
            ccyData.close(tt,nn) = 39.88/39.931 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('20-Nov-2003 21:00:00')); 
            ccyData.close(tt,nn) = 39.90/39.905 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('11-Sep-2005 20:00:00')); 
            ccyData.close(tt,nn) = 0; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('12-Sep-2005 20:00:00')); 
            ccyData.close(tt,nn) = 40.89/40.93 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('13-Sep-2005 20:00:00')); 
            ccyData.close(tt,nn) = 40.91/40.89 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('25-Feb-2008 21:00:00')); 
            ccyData.close(tt,nn) = 32.28/32.3 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('29-Feb-2008 21:00:00')); 
            ccyData.close(tt,nn) = 31.475/32.05 -1; %#ok<FNDSB> 
            tt = find(ccyData.dates == datenum('01-Mar-2008 21:00:00')); 
            ccyData.close(tt,nn) = 0; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('02-Mar-2008 21:00:00')); 
            ccyData.close(tt,nn) = 0; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('03-Mar-2008 21:00:00')); 
            ccyData.close(tt,nn) = 31.625/31.475 -1; %#ok<FNDSB>
        end % if

        nn = find(strcmpi(ccyData.header,'fx.usdbrl'));
        if ~isempty(nn)
            tt = find(ccyData.dates == datenum('29-Oct-2009 20:00:00'));
            ccyData.close(tt,nn) = 1.7328/1.7793 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('27-Nov-2009 21:00:00'));
            ccyData.close(tt,nn) = 1.7408/1.7469 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2010 21:00:00'));
            ccyData.close(tt,nn) = 1.7185/1.7279 -1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('28-Oct-2011 20:00:00'));
            ccyData.close(tt,nn) = 1.6721/1.7099-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Nov-2011 21:00:00'));
            ccyData.close(tt,nn) = 1.8454/1.8547-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('30-Oct-2014 20:00:00'));
            ccyData.close(tt,nn) = 2.4026/2.4619-1; %#ok<FNDSB>
            tt = find(ccyData.dates == datenum('29-Oct-2015 20:00:00'));
            ccyData.close(tt,nn) = 3.8487/3.9061-1; %#ok<FNDSB>
        end
        
%       following code commented out since we are replacing w/ BBG sourcing for now  
%         nn = find(strcmpi(ccyData.header,'fx.usdclp'));
%         if ~isempty(nn)
%             tt = find(ccyData.dates == datenum('11-Feb-2011 21:00:00'));
%             ccyData.close(tt,nn) = 473.78/475.13-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('27-Oct-2011 20:00:00'));
%             ccyData.close(tt,nn) = 492/503.36-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('29-Nov-2011 21:00:00'));
%             ccyData.close(tt,nn) = 526.75/524.75-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('30-Oct-2012 20:00:00'));
%             ccyData.close(tt,nn) = 481.6/484.15-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('29-Nov-2012 21:00:00'));
%             ccyData.close(tt,nn) = 482.33/482.88-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('01-Dec-2014 21:00:00'));
%             ccyData.close(tt,nn) = 614.33/610.2-1; %#ok<FNDSB>
%             tt = find(ccyData.dates == datenum('27-Nov-2015 21:00:00'));
%             ccyData.close(tt,nn) = 716.3/715.25-1; %#ok<FNDSB>
%         end
        
        % now clean TSRP data:
        for i = 1:length(tsrpIDs)
            if strcmpi(tsrpIDs(i),'fx.usdidr') 
                ii = indx(i); 
                i1 = find(strcmpi(bbgFwdsData.header,'IHN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'IHN+2M BGNL Curncy')); 
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2); 
            elseif strcmpi(tsrpIDs(i),'fx.usdinr') 
                ii = indx(i); 
                i1 = find(strcmpi(bbgFwdsData.header,'IRN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'IRN+2M BGNL Curncy')); 
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2); 
            elseif strcmpi(tsrpIDs(i),'fx.usdkrw') 
                ii = indx(i); 
                i1 = find(strcmpi(bbgFwdsData.header,'KWN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'KWN+2M BGNL Curncy')); 
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2); 
            elseif strcmpi(tsrpIDs(i),'fx.usdmyr') 
                ii = indx(i); 
                i1 = find(strcmpi(bbgFwdsData.header,'MRN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'MRN+2M BGNL Curncy')); 
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
            elseif strcmpi(tsrpIDs(i),'fx.usdphp') 
                ii = indx(i);
                i1 = find(strcmpi(bbgFwdsData.header,'PPN+1M BGNL Curncy')); 
                i2 = find(strcmpi(bbgFwdsData.header,'PPN+2M BGNL Curncy')); 
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
            elseif strcmpi(tsrpIDs(i),'fx.usdtwd')
                ii = indx(i);
                i1 = find(strcmpi(bbgFwdsData.header,'NTN+1M BGNL Curncy'));
                i2 = find(strcmpi(bbgFwdsData.header,'NTN+2M BGNL Curncy'));
                % note: due to USDXXX convention we subtract roll-down
                ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
                ptsRoll(abs(ptsRoll)>0.01) = 0;
                ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
                flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates);
                ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           elseif strcmpi(tsrpIDs(i),'fx.usdrub')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'RUB+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'RUB+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           elseif strcmpi(tsrpIDs(i),'fx.usdclp')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'CHN+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'CHN+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
           elseif strcmpi(tsrpIDs(i),'fx.usdcop')
              ii = indx(i);
              i1 = find(strcmpi(bbgFwdsData.header,'CLN+1M BGNL Curncy'));
              i2 = find(strcmpi(bbgFwdsData.header,'CLN+2M BGNL Curncy'));
              % note: due to USDXXX convention we subtract roll-down
              ptsRoll = -(1/30)*(bbgFwdsData.levels(:,i2) - bbgFwdsData.levels(:,i1))./bbgFwdsData.levels(:,i1); %#ok<FNDSB>
              ptsRoll(abs(ptsRoll)>0.01) = 0; 
              ptsRoll = alignNewDatesJC(floor(bbgFwdsData.dates),ptsRoll,floor(ccyData.dates));
              flatRtn = alignNewDates(bbgData.dates,bbgData.values(:,i),ccyData.dates); 
              ccyData.close(:,ii) = nansum([flatRtn,ptsRoll],2);
            else
                ii = indx(i);
                tIndx = find(abs(ccyData.close(:,ii))>threshold(i));
                for j = 1:length(tIndx)
                    dd = ccyData.dates(tIndx(j));
                    t = find(bbgData.dates<=dd,1,'last');
                    if ~isempty(t)
                        ccyData.close(tIndx(j),ii) = bbgData.values(t,i);
                    else
                        ccyData.close(tIndx(j),ii) = NaN;
                    end % if
                end % for j
            end % if
        end % for i 
end % switch 

end % fn