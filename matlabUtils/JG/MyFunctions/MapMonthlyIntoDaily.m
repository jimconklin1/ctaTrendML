function xdaily =  MapMonthlyIntoDaily(tdmBase, MthYeartdaynumJunklag, xlag, method)
%
%__________________________________________________________________________
%
% This function map a monthly time series into a daily time series given by
% a vector of daily dates 'tdmbase'
% method refers to the fact we can get monthly, quarterly, or yearly data
% base
%__________________________________________________________________________
%

    nRows=length(tdmBase);
    xdaily=zeros(nRows,1); % Temporary vector of daily data
    for i=1:nRows
        if tdmBase(i,1)~=0
            tartgetMonth=tdmBase(i,1); % identify the target end ot month in the daily time series
            targetYear=tdmBase(i,2); % identify the target year in the daily time series
            % Locate the Monthly time series and populate daily time series
            for qqq=1:length(xlag)
                if MthYeartdaynumJunklag(qqq,1)==tartgetMonth && MthYeartdaynumJunklag(qqq,2)==targetYear
                    xdaily(i)=xlag(qqq);
                end
            end
        end
    end
    % Fill the zeros
    
    switch method
        
        case {'monthly', 'mth', 'm', 'M'}
    
            for i=2:nRows
                if tdmBase(i,1)==0, xdaily(i)=xdaily(i-1); end
            end
            if tdmBase(nRows,1)~=0 && tdmBase(nRows,3)==0 
                xdaily(i)=xdaily(i-1);
            end
            
        case {'quarterly', 'q', 'Q'}       
            
            for i=2:nRows
                if tdmBase(i,1)==0 || tdmBase(i,1)==1  || tdmBase(i,1)==2 ...
                        || tdmBase(i,1)==4 || tdmBase(i,1)==5 ...
                        || tdmBase(i,1)==7 || tdmBase(i,1)==8 ...
                        || tdmBase(i,1)==10 || tdmBase(i,1)==11  
                    xdaily(i)=xdaily(i-1); 
                end
            end
            
    end
            