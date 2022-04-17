function storeNewTstat (datesIn ,  dataIn, lookbacks ,assets  )
    
    existingTstat= fetchTstats(assets,lookbacks,floor(datesIn(1))-7,floor(datesIn(end))+7); %+7 and -7 are to make 
    %sure we are not over righting anything by mistake (e.g., TK data on Monday after Friday lon)
    [existingTstat.dates,i_a] = setdiff(existingTstat.dates,datesIn,'stable');
    existingTstat.values= existingTstat.values (i_a, :,:); 


    assets0=assets;
    for h =1:length  (assets0)
        if strcmpi ( assets0{h}(1:3), 'fx.')
            assets0{h}= assets0{h}(4:end) ;
        end 
    end
    
    
    
    tempIn.dates = datesIn;
    tempIn.header = assets0;
    tempOld.header = assets0;
    tempOld.dates= existingTstat.dates; 
    for k =1:length (lookbacks)
        tempIn.tstat = dataIn(:,:, k);
        tempOld.tstat = existingTstat.values (:,:, k);
        tstatTableNew = customStruct2Table(tempIn, {'tstat'}, {'.*'}, {});
        tstatTableOld =  customStruct2Table(tempOld, {'tstat'}, {'.*'}, {});
        tstatTable = sortrows([tstatTableNew; tstatTableOld], 1); 
        for n =1 : length(assets)
            key = tstatTable.Properties.VariableNames{n+1};
            tsrp.store_user_daily(strcat('u.d.',key ,'_',num2str(lookbacks(k))), tstatTable(:,[1,n+1]), false);
        end 
    end 






end 
