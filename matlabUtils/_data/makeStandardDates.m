function [dates] = makeStandardDates(begDate,endDate)
% JC: wrote up an oldie-but-goodie for new code libs
begDate0 = floor(begDate); 
endDate0 = floor(endDate); 
adjFactor =  begDate - begDate0;
dates = datenum(begDate0):1:datenum(endDate0); 
dayOfWeek = weekday(dates); 
indx = (dayOfWeek > 1 & dayOfWeek < 7); 
dates = dates(indx)+adjFactor; 
dates = dates'; 
end % fn 