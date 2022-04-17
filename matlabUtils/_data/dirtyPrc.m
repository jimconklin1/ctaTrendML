function dirtyPrice = dirtyPrc(CTickerGen,cdxPrice,BAccruedInt)
    
    
    for j = 1:length(CTickerGen)
        temp = cdxPrice.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC','')));
        if ~isempty(temp)
            tmp = BAccruedInt.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC','')));
            ind1 = ismember(temp.localTime,tmp.localTime);
            ind2 = ismember(tmp.localTime,temp.localTime);
            dTemp = table2array(temp(ind1,3:end)) - repmat(tmp.AccruedIntPct(ind2),1,4);
            dtyPrc = [temp(ind1,1:2) array2table(dTemp)];
            dtyPrc.Properties.VariableNames = {'systemTime','localTime','Open','High','Low','Close'};
            dirtyPrice.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''))) = dtyPrc;
        else
            dirtyPrice.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''))) = [];
        end
    end

end

