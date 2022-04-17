function [BusDates, rtnOut] = addWkndRtns2Mon(datesIn, rtnIn, TZ)
% This function inserts the missing busdays and then carries the weekend
% returns forward (adding to the following monday) 

BusDates = getBusDays (datesIn(1) , datesIn(end), TZ  );
allDates= union (BusDates,datesIn, 'sorted'    );
indx = ~(weekday(allDates)==7|weekday(allDates)==1);
tempRtns = alignNewDatesJC(datesIn,rtnIn ,allDates) ;
T = length(allDates);
for t = 1:T
    if ~indx(t,:)&&  t<T  % weekend, so carry return forward
        temp = [tempRtns(t,:);tempRtns(t+1,:)];
        tempCum= calcCum (temp,1)-1;
        tempRtns(t+1,:)= tempCum(end,:);
        tempRtns(t+1,all(isnan(temp)))=nan; % asset with no retruns on both days, so Nan return.
    end % if
end % for t
rtnOut = tempRtns(indx,:); 
           
end
