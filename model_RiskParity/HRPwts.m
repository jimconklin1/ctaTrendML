function hrpWts = HRPwts(dataStruct)
    
    dates = dataStruct.dates;
    hrpWts520 = ones(length(dataStruct.dates),length(dataStruct.header))./length(dataStruct.header);
    hrpWts260 = ones(length(dataStruct.dates),length(dataStruct.header))./length(dataStruct.header);
    
    totalIndex = 0;
    for i = 1:length(dataStruct.header)
        index = find(isnan(dataStruct.close(:,i))==0,1);
        totalIndex = [totalIndex;index]; %#ok<AGROW>
        start = max(totalIndex);
    end
    
    
    for i = start+520:length(dates)
        rtns520 = dataStruct.close(i-520:i-1,:);
        rtns520(isnan(rtns520)) = 0;
        rtns260 = dataStruct.close(i-260:i-1,:);
        rtns260(isnan(rtns260)) = 0;
        tmp1 = HRPCluster(dataStruct,rtns520);
        if ~isnan(sum(tmp1))
            hrpWts520(i,:) = tmp1;
        end
        tmp2 = HRPCluster(dataStruct,rtns25);
        if ~isnan(sum(tmp2))
            hrpWts260(i,:) = HRPCluster(dataStruct,rtns260);
        end
    end
    
    % hrpWts = 0.5*hrpWts520 + 0.5*hrpWts260;
    hrpWts = hrpWts520;
    
end