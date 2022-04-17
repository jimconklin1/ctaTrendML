function [dataStruct, badTickers] = fetchBbgDataJC(bbgTickers,bbgFields,c,startDate,endDate,freq)
if nargin < 6 || isempty(freq)
   freq = 'daily';
end 
if isnumeric(startDate)
   str1 = datestr(startDate,'mm/dd/yyyy'); 
   str2 = datestr(endDate,'mm/dd/yyyy'); 
else 
   str1 = startDate; 
   str2 = endDate;
end 
if ischar(bbgFields) 
   bbgFields = {bbgFields}; 
end % if
if length(bbgFields)==1 && length(bbgTickers)>1
   bbgFields = repmat(bbgFields,[1,length(bbgTickers)]);
end     

if strcmpi(freq,'daily')
   newDates = makeStandardDates(datenum(str1),datenum(str2)); 
elseif strcmpi(freq,'monthly')
   str2 = datestr(eomonth(endDate,0)); 
   tempData = history(c,bbgTickers{1},bbgFields{1},str1,str2,[freq,{'non_trading_weekdays'}]); 
   if ~iscell(tempData)
      tempData = {tempData}; 
   end 
   newDates = tempData{1}(:,1); 
   newDates = eomonth(newDates,0); 
end 
tempLvls = zeros(size(newDates,1),size(bbgTickers,2)); 

N = length(bbgTickers); 
goodIndx = 1:N; 
badIndx = []; 

% Now transform data to produce returns/changes:
priceData.values = zeros(size(newDates,1),size(bbgTickers,2)); 
for n = 1:N 
   tempData = history(c,bbgTickers{n},bbgFields{n},str1,str2,[freq,{'non_trading_weekdays'}]); 
   if (isstruct(tempData) && ischar(tempData{1}) ) || (iscell(tempData) && isempty(tempData{1})) ...
           || isempty(tempData)
      badIndx = [badIndx,n]; %#ok 
      continue 
   elseif ~isstruct(tempData) && isnumeric(tempData)
      tempData = {tempData}; 
   end
   ttDates = tempData{1}(:,1); 
   if strcmpi(freq,'monthly'); ttDates = eomonth(ttDates,0); end
   dIndx = ismember(ttDates,newDates); 
   ttDates = ttDates(dIndx,:); 
   ttValues = tempData{1}(:,2); 
   ttValues = ttValues(dIndx,:); 
   t1 = find(newDates == ttDates(1,:)); 
   t2 = find(newDates == ttDates(end,:)); 
   tempLvls(t1:t2,n) = ttValues;
   priceData.values(t1:t2,n) = ttValues;
end % for
badTickers = bbgTickers(:,badIndx); 
goodIndx = setdiff(goodIndx,badIndx); 
dataStruct.header = bbgTickers(goodIndx)';
dataStruct.allHeader = bbgTickers; 
dataStruct.dates = newDates; 
dataStruct.values = tempLvls(:,goodIndx); 
dataStruct.levels = priceData.values;
end % function 
