function [ fillTS, fillPX ] = fillOrderMo( minBarTS, minBarPX, orderTS, EODts  )
% Note: we assume that bar at "t" refers to the price at t-1 till t,
% including t and excluding t-1. 

    

        indx = find((minBarTS>=orderTS)&... %the price at orderTS or the first price after that.
            (minBarTS<=EODts)&...      %the prices before the Eod time is the price at x 
            ~isnan(minBarPX) , ...          %the price cant be nan  
             1 ); 

        if isempty (indx)
            error ('couldnt find a price for Market order, either we have no price btw the order and eod time, or order time is after the close!')
        else 
            fillTS = minBarTS(indx); 
            fillPX = minBarPX(indx); 
        end 

end 