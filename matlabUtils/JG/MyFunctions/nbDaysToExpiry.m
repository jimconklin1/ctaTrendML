%__________________________________________________________________________
% Compute the number of days to expiry
% JConklin                                                         Feb 2016
%__________________________________________________________________________
%
function y = nbDaysToExpiry(t, dates, isRollDay, T)
% isRollDay is a vector whose length is the # of periods in the full data
%   sample

% case 1: we are at/near the end of the sample and there are no more
%   "rollDays" on subsequent periods in the sample, so we have to look at
%   the previous roll day and infer the next one:
if sum(isRollDay(t:T))==0 
   tempDates = makeStandardDates(dates(t),dates(t)+40); 
   %tempIsRollDay = identifyRollDay(tempDates, dayOfTheRoll, NthDayOfMonth);
   tempIsRollDay = identifyRollDay(tempDates);
   y = find(tempIsRollDay,1,'first')-1; 
else % case 2: period t occurs before the final roll day in the historical sample:
   counter = 0;
   for i=t:T
      if isRollDay(i) == 0 
         counter = counter + 1; 
      else 
         break 
      end % if 
   end % for 
   y = counter + 1; 
end % if 

end
