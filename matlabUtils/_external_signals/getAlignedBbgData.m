function outStruct = getAlignedBbgData ( c, assetID, startDate,endDate , frec, dataType )


    
    startDate = datestr(startDate,'mm/dd/yyyy'); 
    endDate = datestr(endDate,'mm/dd/yyyy'); 
    if strcmpi(frec,'minute') || strcmpi(frec,'minutes') || strcmpi(frec,'min') || strcmpi(frec,'mins')
        mins = 1; 
    elseif strcmpi(frec,'session') || strcmpi(frec,'sessions') || strcmpi(frec,'hourly')  
        mins = 60; 
    end 
    
    if strcmpi(dataType,'prices') || strcmpi(dataType,'price') ...
            || strcmpi(dataType,'bar') || strcmpi(dataType,'bars') 

        for i=1:length (assetID)
            tempData = timeseries(c,assetID(i),{startDate,endDate},mins,'Trade');
            closeTable= table (tempData(:,1), tempData(:,5) , 'VariableNames',{'dates' , ['d',num2str(i)] } ); 
            rangeTable= table ( tempData(:,1), tempData(:,3)-tempData(:,4), 'VariableNames',{'dates' , ['d',num2str(i)] } ); 
            if i ==1 
                mergedCloseTable = closeTable ; 
                mergedRangeTable = rangeTable ; 
            else 
                mergedCloseTable =outerjoin(mergedCloseTable,closeTable,'MergeKeys',true);
                mergedRangeTable =outerjoin(mergedRangeTable,rangeTable,'MergeKeys',true);
            end
        end
     elseif  strcmpi(dataType,'returns') || strcmpi(dataType,'return') ||...
        strcmpi(dataType,'rtns') || strcmpi(dataType,'rtn')
    
        for i=1:length (assetID)
            tempData = timeseries(c,assetID(i),{startDate,endDate},mins,'Trade');
            toClose= (tempData(:,5) ./ [ 0; tempData(1:end-1,5)] ) -1 ; 
            toHigh= (tempData(:,3) ./ [ 0; tempData(1:end-1,5)] ) -1 ; 
            toLow= (tempData(:,4) ./ [ 0; tempData(1:end-1,5)] ) -1 ; 
            closeTable= table (tempData(:,1), toClose , 'VariableNames',{'dates' , ['d',num2str(i)] } ); 
            rangeTable= table ( tempData(:,1), toHigh-toLow, 'VariableNames',{'dates' , ['d',num2str(i)] } ); 
            if i ==1 
                mergedCloseTable = closeTable ; 
                mergedRangeTable = rangeTable ; 
            else 
                mergedCloseTable =outerjoin(mergedCloseTable,closeTable,'MergeKeys',true);
                mergedRangeTable =outerjoin(mergedRangeTable,rangeTable,'MergeKeys',true);
            end
        end
    
    
    
    
    end 
        outStruct.header = assetID;
        outStruct.dates  = mergedCloseTable.dates;
        outStruct.close = table2array(mergedCloseTable(:,2:end)); 
        outStruct.range = table2array(mergedRangeTable(:,2:end)); 





    
    
end 