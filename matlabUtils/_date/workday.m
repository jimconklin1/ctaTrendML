function outDates = workday(inDates,shift)
% maps calendar days into working days of the week
% shift = 0:   shift = 1:   shift = -1:
% 1 --> 2       1 --> 2       1 --> 6      
% 2 --> 2       2 --> 3       2 --> 6 
% 3 --> 3       3 --> 4       3 --> 2      
% 4 --> 4       4 --> 5       4 --> 3 
% 5 --> 5       5 --> 6       5 --> 4 
% 6 --> 6       6 --> 2       6 --> 5 
% 7 --> 2       7 --> 2       7 --> 6 

outDates = inDates;
drctn = sign(shift);
mag = abs(shift); 
if mag > 1
   outDates = inDates + drctn*(mag - 1); 
end % if

switch drctn
   case -1 
      indx = find(ismember(weekday(outDates),3:7)); % Tues - Sat
      outDates(indx,:) = outDates(indx,:)-1; 
      indx = find(ismember(weekday(outDates),2)); % Mon
      outDates(indx,:) = outDates(indx,:)-3; 
      indx = find(ismember(weekday(outDates),1)); % Sun
      outDates(indx,:) = outDates(indx,:)-2;       
   case 0
      indx = find(ismember(weekday(outDates),2:6)); % Mon - Fri
      outDates(indx,:) = outDates(indx,:); 
      indx = find(ismember(weekday(outDates),1)); % Sun
      outDates(indx,:) = outDates(indx,:)+1; 
      indx = find(ismember(weekday(outDates),7)); % Sat
      outDates(indx,:) = outDates(indx,:)+2;       
   case 1  
      indx = find(ismember(weekday(outDates),1:5)); % Sun - Thu
      outDates(indx,:) = outDates(indx,:)+1; 
      indx = find(ismember(weekday(outDates),7)); % Sat
      outDates(indx,:) = outDates(indx,:)+2; 
      indx = find(ismember(weekday(outDates),6)); % Friday
      outDates(indx,:) = outDates(indx,:)+3;       
end % switch
end % fn