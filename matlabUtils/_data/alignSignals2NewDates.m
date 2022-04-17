function [outData, newDates, outIndex] = alignSignals2NewDates(dates0, data0, sigDates)
% The function realigns signal data. The function:
%     * unlike alignRtns2NewDates(), this function does not sum a time block (e.g., t1:t2)
%       from data0 into a single record (tt) in outData(tt,:); this fn does
%       not preserve 
%     * assumes chronological ordering
%     * "sigDates" correspond to data such as signals that must be before or
%       at the same time of day as dates0; if the time of day of
%       outDate(t) is greater than dates0(tt), the signals associated with
%       data0(tt) must be attributed to outData(t+1,:).
%     * if floor(sigDates(t)) does not have an associated floor(dates0(t)), then the 
%       returns in outData(t) must = 0.
%     * outIndex DOES NOT map data0 into outData, since it is possible for
%       multiple data0 element to be summed into a single outData row.  It
%       does denote the first, of possible multiple data0 entries, mapped
%       into the outData element.

[T,nAssets] = size(data0);
TT = length(sigDates);
outData = zeros(TT,nAssets); 
outIndex = zeros(TT,1); 
rTOD = mod(dates0(end,:),1);
newDates = floor(sigDates)+rTOD; 

% fill dates previous to valid "in" dates0 w/ zeros:
tt0 = find(floor(sigDates)<floor(dates0(1)),1,'last'); 
if ~isempty(tt0) 
   outData(1:tt0,:) = 0; 
   outIndex(1:tt0,1) = 0; 
   tt0 = find(floor(sigDates)==floor(dates0(1)),1,'last');
else
   tt0 = find(floor(sigDates)>=floor(dates0(1)),1,'first');
end

% determine the last period in outdata you will need to assign a return to:
tt1 = find(sigDates<=dates0(T,:),1,'last'); 
if isempty(tt1) 
    tt1 = TT; 
else 
    outData(tt1,:) = data0(T,:); 
end % if

% loop through dates and assign (sum) returns to appropriate periods:
for tt = tt0:tt1-1
   t = find((dates0 < sigDates(tt+1)) & (dates0 >= sigDates(tt))); 
   if ~isempty(t)
      outData(tt,:) = data0(t(end),:); 
      outIndex(tt,1) = t(end);
   end % if
end % for

% end case if outData dates extend beyond data0 dates:
if TT > tt1
   outIndex(tt,1) = T+1;
end % if

end % fn