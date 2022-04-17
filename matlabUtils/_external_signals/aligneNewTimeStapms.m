function  dataOut  = aligneNewTimeStapms( datesIn, dataIn , datesOut    )
%ALIGNENEWDATESMINUTES Summary of this function goes here
%   Detailed explanation goes here
    
    [intersectDatesIn,~,ib] = intersect(datesOut,datesIn) ; 
    intersectDataIn = dataIn (ib, :); 
    dataTableIn= table (  intersectDatesIn,intersectDataIn , 'VariableNames',{'dates' , 'd1' } ); 
    dataTableOut= table (  datesOut  , 'VariableNames',{'dates'  } ); 
    mergedTable =outerjoin(dataTableOut,dataTableIn,'MergeKeys',true);
    dataOut = table2array(mergedTable(:,2)) ; 

    

end

