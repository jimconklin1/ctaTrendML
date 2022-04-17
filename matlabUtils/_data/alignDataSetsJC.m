function [data1out, data2out, dates3, indx3, t0] = alignDataSetsJC(data1,dates1,data2,dates2,isrets1,nullParam1,isrets2,nullParam2,cleanOpt)
% Note: this function takes an ordered union of dates ( dates3 =
%   union(dates1,dates2) ), and aligns two data sets to those dates.
% In addition,
if nargin < 9
    cleanOpt = false;
end
dates3 = makeStandardDates(min(dates1(1),dates2(1)),max(dates1(end),dates2(end)));
if nargin < 6 || isempty(nullParam1)
    data1out = alignNewDatesJC(dates1, data1, dates3);
    t0a = calcFirstActive(data1,false);
    nullParam1 = [];
else
    data1out = alignNewDatesJC(dates1, data1, dates3, nullParam1);
    t0a = calcFirstActive(data1,true,nullParam1+1.0e-315);
end
if nargin < 8 || isempty(nullParam2)
    data2out = alignNewDatesJC(dates2, data2, dates3);
    t0b = calcFirstActive(data2,false); % if isRets == true, the assumes base value always 0, not NaN, as w/ this series.
    nullParam2 = [];
else
    data2out = alignNewDatesJC(dates2, data2, dates3, nullParam2);
    t0b = calcFirstActive(data2,true,nullParam2+1.0e-315);
end
if ~cleanOpt
      indx3 = 1:length(dates3); 
      t0 = 1;
else 
   t0 = max([t0a; t0b]); 
   
   % create an index for jointly clean data:
   if isempty(nullParam1)
      if isrets1
         indx1 = ~isnan(data1out)&~(data1out==2.12199579050000e-314); 
      else
         indx1 = ~isnan(data1out); 
      end
   else
      if isrets1
         indx1 = ~isnan(data1out)&~(data1out==nullParam1);  
      else
         indx1 = ~isnan(data1out)&~(data1out==nullParam1); 
      end
   end
   if isempty(nullParam2)
      if isrets2
         indx2 = ~isnan(data2out)&~(data2out==2.12199579050000e-314);
      else
         indx2 = ~isnan(data2out);
      end
   else
      if isrets2
         indx2 = ~isnan(data2out)&~(data2out==nullParam2)&~(data2out==2.12199579050000e-314);
      else
         indx2 = ~isnan(data2out)&~(data2out==nullParam2);
      end
   end
   indx3 = indx1 & indx2; 
end % if
end % function