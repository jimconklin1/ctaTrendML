function spliceGen(tsrpTickers,startDate,endDate)
    
    genTickers = tsrpTickers;
    for i = 1:length(tsrpTickers)
        tmp = tsrpTickers(i);
        index = cell2mat(strfind(tmp,'_S'));
        tmp{:}(index:index+3) = char('_GEN');
        genTickers(i) = tmp;        
    end
    
    for j = 1:length(tsrpTickers)         
        temp = tsrp.fetch_user_daily(cellstr(strcat('u.d.cdx_',lower(char(tsrpTickers(j))))),datestr(startDate,'yyyy-mm-dd'),datestr(endDate,'yyyy-mm-dd'),'');
        genName = char(genTickers(j));
        tsrp.init('prod');
        tsrp.store_user_daily(strcat('u.d.cdx_',lower(genName)), temp, false);      
        %tsrp.init('qa');
        %tsrp.store_user_daily(strcat('u.d.cdx_',lower(genName)), temp, false);
    end
    
end