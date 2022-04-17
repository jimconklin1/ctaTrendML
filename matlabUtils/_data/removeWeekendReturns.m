function [outDates,outRtns] = removeWeekendReturns(inDates,inRtns)
indx = ~(weekday(inDates)==7|weekday(inDates)==1); 
outDates = inDates(indx,:);
tempRtns = zeros(size(inRtns)); 
T = length(inDates); 
for t = 1:T
   if indx(t,:) % weekday
      tempRtns(t,:) = nansum([tempRtns(t,:);inRtns(t,:)]); 
   elseif  t<T % weekend, so carry return forward
      tempRtns(t+1,:) = nansum([tempRtns(t+1,:);inRtns(t,:)]); 
   end % if 
end % for t 
outRtns = tempRtns(indx,:); 
end % fn 