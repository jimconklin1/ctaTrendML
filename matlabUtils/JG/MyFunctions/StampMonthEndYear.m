function y =  StampMonthEndYear(x)
%
%__________________________________________________________________________
%
% This function identify end of month and year
% Need date on format "num"
%__________________________________________________________________________
%

    y=zeros(length(x),2);
    nRows=length(x);
    
    for qqq=1:nRows
        if x(qqq)~=0
            y(qqq,1)=month(x(qqq));
            y(qqq,2)=year(x(qqq));
        end
    end