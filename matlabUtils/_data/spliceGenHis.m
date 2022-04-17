function spliceGenHis(CTickerAll,seriesInfo)
    
    name = cellstr(char(strrep(strrep(CTickerAll,' ','_'),'_PRC','')));

    for j = 1:length(CTickerAll) 
        series = 17:cell2Num(seriesInfo.current_series(j));
        name_first = char(strrep(strrep(strrep(CTickerAll(j),' ','_'),'_PRC',''),'GEN',strcat('S',num2str(series(1)))));
        name_gen = char(strrep(strrep(CTickerAll(j),' ','_'),'_PRC',''));
        temp_first0.(char(name_first)) = tsrp.fetch_user_daily(cellstr(strcat('u.d.cdx_',lower(name_first))),'2011-01-01','2017-06-01','');
        temp_second = temp_first0;
        temp_first.(char(name_gen)) = tsrp.fetch_user_daily(cellstr(strcat('u.d.cdx_',lower(name_first))),'2011-01-01','2017-06-01','');
    end
    for j = 1:length(CTickerAll)
        series = 17:cell2Num(seriesInfo.current_series(j));
        for k = 2:length(series)              
            name_gen = char(strrep(strrep(CTickerAll(j),' ','_'),'_PRC',''));
            name_second = char(strrep(strrep(strrep(CTickerAll(j),' ','_'),'_PRC',''),'GEN',strcat('S',num2str(series(k)))));            
            temp_second.(char(name_second)) = tsrp.fetch_user_daily(cellstr(strcat('u.d.cdx_',lower(name_second))),'2011-01-01','2017-06-01','');
            index = find((temp_first.(char(name_gen)).utc_time)<=(temp_second.(char(name_second)).utc_time(1)));
            temp.(char(name(j))) = [temp_first.(char(name_gen))(1:index(end),:);temp_second.(char(name_second))(2:end,:)];
            temp_first.(char(name(j))) = temp.(char(name(j)));
        end        
    end
    
    genNames = fields(temp);
    for j = 1:length(CTickerAll)          
        genName = char(genNames(j));
        tsrp.init('prod');
        outputs = temp_first.(char(genName));
        tsrp.store_user_daily(strcat('u.d.cdx_',lower(genName)), outputs, true);

        %tsrp.init('qa');
        %tsrp.store_user_daily(strcat('u.d.cdx_',lower(genName)), output, true);

    end
    
end