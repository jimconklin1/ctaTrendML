function saveCdxToTSRP(CTickerAll,CTickerGen,cdxPrice,cdxSpread,BAccruedInt,dirtyPrice,dirtyPrcRtns,CTickerInfo)    

    for j = 1:length(CTickerGen)
        
        if ismember(CTickerAll(j),{'CDX EM CDSI GEN 5Y PRC Corp','CDX HY CDSI GEN 5Y PRC Corp','CDX IG CDSI GEN 5Y Corp'})
            fromTimeZone = 'America/New_York';
        elseif ismember(CTickerAll(j),{'SNRFIN CDSI GEN 5Y Corp','ITRX EUR CDSI GEN 5Y Corp','ITRX XOVER CDSI GEN 5Y Corp','SUBFIN CDSI GEN 5Y Corp'})
            fromTimeZone = 'Europe/London';
        elseif ismember(CTickerAll(j),{'ITRX AUS CDSI GEN 5Y Corp'})
            fromTimeZone = 'Australia/Sydney';
        elseif ismember(CTickerAll(j),{'ITRX JAPAN CDSI GEN 5Y Corp'})
            fromTimeZone = 'Asia/Tokyo';
        end
        toTimeZone = 'UTC';
        
        name = char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''));
        
        price = cdxPrice.(name);
        if ~isempty(price)
            price.Properties.VariableNames = {'sgTime','localTime','clnPrc_open','clnPrc_high','clnPrc_low','clnPrc_close'};
            spread = cdxSpread.(name);
            spread.Properties.VariableNames = {'sgTime','localTime','sprd_open','sprd_high','sprd_low','sprd_close'};
            accInt = BAccruedInt.(name);
            dPrice = dirtyPrice.(name);
            dPrice.Properties.VariableNames = {'sgTime','localTime','drtPrc_open','drtPrc_high','drtPrc_low','drtPrc_close'};
            rtns = dirtyPrcRtns.(name);
            rtns.Properties.VariableNames = {'sgTime','localTime','rtns_open','rtns_high','rtns_low','rtns_close'};
            infos = CTickerInfo.(name);
            tickerLocalTime = array2table(cellstr(datestr([year(price.localTime), month(price.localTime), day(price.localTime), zeros(size(price,1),1),zeros(size(price,1),1),zeros(size(price,1),1)])),'VariableNames',{'localTime'}); %#ok<NASGU>
            tempTime = datestr([year(price.localTime), month(price.localTime), day(price.localTime), repmat(17,size(price,1),1),repmat(15,size(price,1),1),zeros(size(price,1),1)]);
            utcTime = datetime(tempTime,'TimeZone',fromTimeZone);
            utcTime.TimeZone = toTimeZone; 
            %utcTimes = array2table(cellstr(datestr([year(utcTime), month(utcTime), day(utcTime), zeros(size(utcTime,1),1),zeros(size(utcTime,1),1),zeros(size(utcTime,1),1)],'yyyy-mm-dd HH:MM:SS')),'VariableNames',{'utc_time'});
            utcTimes = array2table(datenum(datestr([year(utcTime), month(utcTime), day(utcTime), zeros(size(utcTime,1),1),zeros(size(utcTime,1),1),zeros(size(utcTime,1),1)],'yyyy-mm-dd HH:MM:SS')),'VariableNames',{'utc_time'});
            openTime = datestr([year(price.localTime), month(price.localTime), day(price.localTime), repmat(8,size(price,1),1),zeros(size(price,1),1),zeros(size(price,1),1)]);
            utcOpenTime = datetime(openTime,'TimeZone',fromTimeZone);
            utcOpenTime.TimeZone = toTimeZone; 
            utcOpenTime = array2table(datenum(utcOpenTime),'VariableNames',{'utc_open_time'});
            closeTime = datestr([year(price.localTime), month(price.localTime), day(price.localTime), repmat(17,size(price,1),1),repmat(15,size(price,1),1),zeros(size(price,1),1)]);
            utcCloseTime = datetime(closeTime,'TimeZone',fromTimeZone);
            utcCloseTime.TimeZone = toTimeZone; 
            utcCloseTime = array2table(datenum(utcCloseTime),'VariableNames',{'utc_close_time'});
            rollDt = datestr([year(infos.rollDt), month(infos.rollDt), day(infos.rollDt), repmat(8,size(price,1),1),zeros(size(price,1),1),zeros(size(price,1),1)]);
            rollDt = datetime(rollDt,'TimeZone',fromTimeZone);
            rollDt.TimeZone = toTimeZone; 
            rollDt = array2table(datenum(rollDt ),'VariableNames',{'rollDt'});
            allInfo = [utcTimes utcOpenTime utcCloseTime price(:,3:end) spread(:,3:end) dPrice(:,3:end) rtns(:,3:end) accInt(:,2:end) infos(:,2:end-1) rollDt];
            returns = [utcTimes utcOpenTime utcCloseTime rtns(:,3:end) spread(:,3:end)];
        
        
            tsrp.init('prod');
            %tsrp.store_user_daily(strcat('u.d.cdxall_',lower(name)), allInfo, true);
            %tsrp.store_user_daily(strcat('u.d.cdx_',lower(name)), returns, true);
            tsrp.store_user_daily(strcat('u.d.cdxall_',lower(name)), allInfo(2:end,:), false);
            tsrp.store_user_daily(strcat('u.d.cdx_',lower(name)), returns(2:end,:), false);
        
            tsrp.init('qa');
            %tsrp.store_user_daily(strcat('u.d.cdxall_',lower(name)), allInfo, true);
            %tsrp.store_user_daily(strcat('u.d.cdx_',lower(name)), returns, true);
            tsrp.store_user_daily(strcat('u.d.cdxall_',lower(name)), allInfo(2:end,:), false);
            tsrp.store_user_daily(strcat('u.d.cdx_',lower(name)), returns(2:end,:), false);      
        end
        
    end

end

