function [outData, newDates, outIndex] = alignRtns2NewDates(rtnDates, rtnData, sigDates)
% The function realigns rtnData returns by business sigDates; The function:
%     * assumes chronological ordering
%     * "sigDates" correspond to data such as signals that must be before or
%       at the same time of day as rtnDates; if the time of day of
%       outDate(t) is greater than rtnDates(tt), the returns associated with
%       rtnData(tt) must be attributed to outData(t+1,:).
%     * if floor(sigDates(t)) does not have an associated floor(rtnDates(t)), then the 
%       returns in outData(t) must = 0.
%     * the fn imposes the following condition: sum(outData) = sum(rtnData)
%     * outIndex DOES NOT map rtnData into outData, since it is possible for
%       multiple rtnData element to be summed into a single outData row.  It
%       does denote the first, of possible multiple rtnData entries, mapped
%       into the outData element.

[T,nAssets] = size(rtnData);
TT = length(sigDates);
outData = zeros(TT,nAssets); 
outIndex = zeros(TT,1); 
rTOD = mod(rtnDates(end,:),1);
newDates = floor(sigDates)+rTOD; 

% fill dates previous to valid "in" rtnDates w/ zeros:
tt0 = find(floor(sigDates)<floor(rtnDates(1)),1,'last'); 
if ~isempty(tt0) 
   outData(1:tt0,:) = 0; 
   outIndex(1:tt0,1) = 0; 
   tt0 = find(floor(sigDates)==floor(rtnDates(1)),1,'last');
else
   tt0 = find(floor(sigDates)>=floor(rtnDates(1)),1,'first');
end

% determine the last period in outdata you will need to assign a return to:
tt1 = find(sigDates<=rtnDates(T,:),1,'last'); 
if isempty(tt1) 
    tt1 = TT; 
else 
    outData(tt1,:) = nansum(rtnData(T,:),1); 
end % if

% loop through dates and assign (sum) returns to appropriate periods:
for tt = tt0:tt1-1
   t = find((rtnDates < sigDates(tt+1)) & (rtnDates >= sigDates(tt))); 
   if ~isempty(t)
      outData(tt,:) = nansum(rtnData(t,:),1); 
      outIndex(tt,1) = t(1);
   end % if
end % for

% end case if outData dates extend beyond rtnData dates:
if TT > tt1
   outIndex(tt,1) = T+1;
end % if

end % fn