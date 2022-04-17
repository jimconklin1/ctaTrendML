function dirtyPrcRtns = dtyPrcRtns(CTickerGen,dirtyPrice)    
    for j = 1:length(CTickerGen)
        temp = dirtyPrice.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC','')));
        if ~isempty(temp)
            rtns = temp;
            for i = 2:size(temp,1)
                if temp.Close(i-1) ~= 0
                    rtns.Open(i) = (temp.Open(i) - temp.Close(i-1))/temp.Close(i-1); 
                    rtns.High(i) = (temp.High(i) - temp.Close(i-1))/temp.Close(i-1); 
                    rtns.Low(i) = (temp.Low(i) - temp.Close(i-1))/temp.Close(i-1); 
                    rtns.Close(i) = (temp.Close(i) - temp.Close(i-1))/temp.Close(i-1); 
                else
                    rtns.Open(i) = 0; 
                    rtns.High(i) = 0; 
                    rtns.Low(i) = 0; 
                    rtns.Close(i) = 0; 
                end

            end
            rtns(1,3) = array2table(0);
            rtns(1,4) = array2table(0);
            rtns(1,5) = array2table(0);
            rtns(1,6) = array2table(0);
            dirtyPrcRtns.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''))) = rtns;
        else
            dirtyPrcRtns.(char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''))) = [];
        end
    end

end

