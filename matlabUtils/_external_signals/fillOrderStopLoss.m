
function [ fillTS, fillPX ] = fillOrderStopLoss( minBarTS, minBarPX, orderTS,uptoTS,  buysell, f1  )

 
    indx = find((minBarTS>=orderTS)&... %the price at orderTS or the first price after that.
                (minBarTS<=uptoTS)&...      %the price before the close (not equal becasue of out minute bar convention- referring to the end of minute bar)
                ~isnan(minBarPX), 1);         %the price cant be nan  

    if isempty (indx) 
        if minutes(datetime(uptoTS, 'ConvertFrom', 'datenum') - datetime(orderTS, 'ConvertFrom', 'datenum'))>=15*60
        error ('couldnt find a price for s/l, either we have no price or order time is after the close!')
        else
            fillPX =nan;
            fillTS= nan;
        end 
            
    else 
         if buysell ==1 % we are short, s/t long, market below s/l price, first bar that goes above f1
                 i= find (minBarPX>=f1&minBarTS>=orderTS&minBarTS<=uptoTS , 1); 
         else % we are long, so s/t short,  market above s/l price, first bar that goes below f1
             i= find (minBarPX<=f1&minBarTS>=orderTS&minBarTS<=uptoTS , 1);
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
