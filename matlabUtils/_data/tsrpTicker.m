function tsrpTickers = tsrpTicker(latestTickers,newestTickers)
    
    tmp1 = latestTickers;
    for i = 1:length(tmp1)
        tmp = tmp1(i);
        index = cell2mat(strfind(tmp,'_S'));
        tmp1(i) = cellstr(tmp{:}(1:index-1));        
    end
    
    tmp2 = newestTickers;
    for i = 1:length(tmp2)
        tmp = tmp2(i);
        index = cell2mat(strfind(tmp,'_S'));
        tmp2(i) = cellstr(tmp{:}(1:index-1));        
    end
    
    tsrpTickers = [newestTickers;latestTickers(~ismember(tmp1,tmp2))];
 
end