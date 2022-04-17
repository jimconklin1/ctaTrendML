function CTickerInfo = GetCDSInfo(ctx,CTicker,CTickerName,cdxPrice)
    % get dividend detailed information and traded time zone

    for j = 1:length(CTicker)

        prc = cdxPrice.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC','')));
        if ~isempty(prc)
            dayRange = prc.localTime;

            TickerInfo = array2table(nan(length(dayRange), 5),'VariableNames',{'date','coupon','notional','factor','initialDt'});

        
            for i = 1:length(dayRange)
            	swapDt = datestr(dayRange(i),'yyyymmdd');
                tickerInfos = getdata(ctx.bbgConn,CTicker(j),{'SW_SPREAD','SW_PAY_NOTL_AMT','PX_POS_MULT_FACTOR','HISTORY_START_DT'},'SW_CURVE_DT',swapDt);
                if iscell(tickerInfos.SW_SPREAD)
                    tickerInfos = getdata(ctx.bbgConn,CTicker(j),{'SW_SPREAD','SW_PAY_NOTL_AMT','PX_POS_MULT_FACTOR','HISTORY_START_DT'},'SW_CURVE_DT',swapDt);
                end
                TickerInfo.date(i) = datenum(dayRange(i));
                if ~iscell(tickerInfos.SW_SPREAD)
                    TickerInfo.coupon(i) = tickerInfos.SW_SPREAD;
                else
                    TickerInfo.coupon(i) = table2array(cell2table(tickerInfos.SW_SPREAD));
                end
                if ~iscell(tickerInfos.SW_PAY_NOTL_AMT)
                    TickerInfo.notional(i) = tickerInfos.SW_PAY_NOTL_AMT;       
                else
                    TickerInfo.notional(i) = table2array(cell2table(tickerInfos.SW_PAY_NOTL_AMT));
                end
                if ~iscell(tickerInfos.PX_POS_MULT_FACTOR)
                    TickerInfo.factor(i) = tickerInfos.PX_POS_MULT_FACTOR;     
                else
                    TickerInfo.factor(i) = table2array(cell2table(tickerInfos.PX_POS_MULT_FACTOR));
                end
                if ~iscell(tickerInfos.HISTORY_START_DT)
                    TickerInfo.initialDt(i) = tickerInfos.HISTORY_START_DT;    
                else
                    TickerInfo.initialDt(i) = table2array(cell2table(tickerInfos.HISTORY_START_DT));
                end
            end
            temp = [cellstr(datestr(TickerInfo.date)) TickerInfo(:,2:end-1) cellstr(datestr(table2array(TickerInfo(:,end))))];
            temp.Properties.VariableNames = {'localTime','coupon','notional','factor','rollDt'};
            CTickerInfo.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC',''))) = temp;
        else
            CTickerInfo.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC',''))) = [];
        end
    end
    
    
end
