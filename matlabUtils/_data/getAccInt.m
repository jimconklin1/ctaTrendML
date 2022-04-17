function BAccruedInt = getAccInt(ctx,CTicker,CTickerInfo,CTickerName,cdxPrice)
% pull accrued interest directly from bloomberg
fprintf('%s: pull accrued interest starting time.\n', datestr(datetime()));


for j= 1:length(CTicker)
    name = strrep(strrep(CTickerName(j),' ','_'),'_PRC','');
    prc = cdxPrice.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC','')));
    if ~isempty(prc)
        dayRange = prc.localTime;
        BAccruedIntAmt = zeros(length(dayRange), 1);
        BAccruedIntPct = zeros(length(dayRange), 1);

        for i = 1:length(dayRange)
            bAccInt = getdata(ctx.bbgConn,CTicker(j),{'SW_PAY_ACC_INT'},{'SW_CURVE_DT'},cellstr(datestr(datenum(dayRange(i)),'yyyymmdd')));
            if ~isnumeric(bAccInt.SW_PAY_ACC_INT)   
                bAccInt = getdata(ctx.bbgConn,CTicker(j),{'SW_PAY_ACC_INT'},{'SW_CURVE_DT'},cellstr(datestr(datenum(dayRange(i)),'yyyymmdd')));
            end
            if ~isnumeric(bAccInt.SW_PAY_ACC_INT)   
                bAccInt.SW_PAY_ACC_INT = 0;
            end
            tempPrc = sum(table2array(prc(i,3:end)));
            if tempPrc ~= 0
                BAccruedIntAmt(i) = bAccInt.SW_PAY_ACC_INT;
                index = ismember(datenum(CTickerInfo.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC',''))).localTime),datenum(dayRange(i)));
                temp = CTickerInfo.(char(strrep(strrep(CTickerName(j),' ','_'),'_PRC',''))).notional;
                BAccruedIntPct(i) = bAccInt.SW_PAY_ACC_INT/(temp(index))*100;
            end
        end
        stats = [dayRange array2table([BAccruedIntAmt BAccruedIntPct])];
        stats.Properties.VariableNames = {'localTime','AccruedIntAmt','AccruedIntPct'};
        BAccruedInt.(char(name)) = stats;
    else
        BAccruedInt.(char(name)) = [];
    end
end

fprintf('%s: pull accrued interest ending time.\n', datestr(datetime()));
end