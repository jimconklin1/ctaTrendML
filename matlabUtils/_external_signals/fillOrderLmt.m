
function [ fillTS, fillPX ] = fillOrderLmt( minBarTS, minBarPX, orderTS,EODts,  buysell, f1  )


    indx = find((minBarTS>=orderTS)&... %the price at orderTS or the first price after that.
                (minBarTS<=EODts)&...      %the price before the close  
                ~isnan(minBarPX));         %the price cant be nan  

    if isempty (indx)
        error ('couldnt find a price for limit order, either we have no price or order time is after the close!')
    else 
         if ( buysell ==1 && minBarPX(indx(1)) < f1) || ... % buy limit and market blow limit price 
                 ( buysell ==-1  && minBarPX(indx(1))>f1)  % sell limit and market above limit price 
                 
             fillTS= minBarTS(indx(1)); 
             fillPX= minBarPX(indx(1)); 
             
         else
             if buysell ==1 % buy limit and market above limit price
                 i= find (minBarPX<=f1&minBarTS>=orderTS&minBarTS<=EODts , 1); 
             else % sell  limit and market below limit price
                 i= find (minBarPX>=f1&minBarTS>=orderTS&minBarTS<=EODts , 1);
             end 
             
            if ~isempty(i)
                fillPX = f1 ;
                fillTS=  minBarTS(i);
            else 
                fillPX =nan;
                fillTS= nan;
            end 
         end 
    end 
                
     
end 
