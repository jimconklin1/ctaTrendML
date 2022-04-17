function y =  StampMonthEndYear_FillMissing(x, method)
%
%__________________________________________________________________________
%
% This function fills the the missing months & years stamps
% method refers to the fact we can get monthly, quarterly, or yearly data
% base
%__________________________________________________________________________
%

    nRows=length(x);
    
    StartRow=find(x(:,1)==0);
 
    switch method
    
    case {'monthly', 'mth', 'm', 'M'}
    
        for qqq=StartRow:nRows
            if x(qqq-1,1)<=11
                x(qqq,1)=x(qqq-1,1)+1;
                x(qqq,2)=x(qqq-1,2);
            elseif x(qqq-1,1)==12
                x(qqq,1)=1;
                x(qqq,2)=x(qqq-1,2)+1;                
            end
        end
        
    case {'quarterly', 'q', 'Q'}
            
        for qqq=StartRow:nRows
            if x(qqq-1,1)<=12
                x(qqq,1)=x(qqq-1,1)+3;
                x(qqq,2)=x(qqq-1,2);
            elseif x(qqq-1,1)==12
                x(qqq,1)=3;
                x(qqq,2)=x(qqq-1,2)+1;                
            end
        end            
            
    end
    
    y=x;