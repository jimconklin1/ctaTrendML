function [badTickers,outStruct] = fetchBbgEquityRtnsJC(bbgTickers,startDate,endDate,c,freq,nanVal,newDates)

% parse inputs: 
if nargin < 7 
   newDates = []; 
else 
   startDate = newDates(1); 
   endDate = newDates(end); 
end % if

if nargin < 6 || isempty(nanVal)
    nanVal = 0; 
end % if

if nargin < 5 || isempty(freq)
    freq = 'daily'; 
end % if

if nargin < 4 || isempty(c)
   try
      c = evalin('caller','c'); 
   catch
      c = blp; 
   end % try
end % if


if isempty(newDates) 
    if (nargin < 3 || isempty(endDate))
       endDate = today(); 
    end
    if ischar(startDate)
       startDate = datenum(startDate); 
    end 
    if ischar(endDate)
       endDate = datenum(endDate); 
    end
    newDates = makeStandardDates(startDate,endDate); 
end 

if size(bbgTickers,1) > size(bbgTickers,2)
   bbgTickers = bbgTickers';
end % if

% deal with duplicate tickers:
[bbgTickers,~,indxC] = unique(bbgTickers);

% set paths, define vars:
str1 = datestr(startDate,'mm/dd/yyyy'); 
str2 = datestr(endDate,'mm/dd/yyyy'); 
tempData = history(c,bbgTickers,{'PX_LAST'},str1,str2,[freq,{'non_trading_weekdays'}]); 
tempData2 = history(c,bbgTickers,{'DAY_TO_DAY_TOT_RETURN_GROSS_DVDS'},str1,str2,[freq,{'non_trading_weekdays'}]); 
N = length(bbgTickers); 
badIndx = []; 

% Now align returns: 
for n = 1:N
    if iscell(tempData) && ischar(tempData{n})
       badIndx = [badIndx,n]; %#ok
    elseif ~iscell(tempData) && isnumeric(tempData)
       tempData = {tempData}; 
    end
%     if iscell(tempData2) && ischar(tempData2{n})
%        badIndx = [badIndx,n]; %#ok
%     elseif
    if ~iscell(tempData2) && isnumeric(tempData2)
       tempData2 = {tempData2}; 
    end
    
    % Align Bloomberg HP to our output dates
    if ~isempty(tempData{n})
       tempData{n} = [newDates, alignNewDatesJC(tempData{n}(:,1), tempData{n}(:,2), newDates)];
    end 
    if ~isempty(tempData2{n})
       tempData2{n} = [newDates, alignNewDatesJC(tempData2{n}(:,1), tempData2{n}(:,2), newDates)];
    else
       tempData2{n} = [newDates, nan(size(newDates))];
    end
end
badTickers = bbgTickers(:,badIndx); 
goodIndx = setdiffJC(1:N,badIndx); 
indxC = setdiffJC(indxC,badIndx); 
M = length(goodIndx); 
% ttDates = tempData{goodIndx(1)}(:,1);
% ttDates2 = tempData2{goodIndx(1)}(:,1);
values = zeros(length(newDates),M); 
values2 = values; 
for n = goodIndx
   ttDates = tempData{n}(:,1);
   dIndx = ismember(ttDates,newDates);
%   ttDates2 = tempData2{n}(:,1);
%   dIndx2 = ismember(ttDates2,newDates);
%   ttDates = ttDates(dIndx,:);
%   ttDates2 = ttDates2(dIndx2,:);
   ttValues = tempData{n}(:,2);
   ttValues2 = tempData2{n}(:,2);
   temp = 0; 
   temp2 = 0; 
   for tt = 1:length(dIndx)
      if dIndx(tt)
         t = find(newDates==ttDates(tt,:)); 
         values(t,n) = (temp + ttValues(tt,1))'; 
         temp = 0; 
         values2(t,n) = temp2 + ttValues2(tt,1); 
         temp2 = 0; 
      else 
         temp = ttValues(tt,1);
         temp2 = ttValues2(tt,1);
      end % if
   end % for tt
%    ttValues = ttValues(dIndx,:);
%    ttValues2 = ttValues2(dIndx2,:);
%    t1 = find(newDates == ttDates(1,:));
%    t2 = find(newDates == ttDates(end,:));
%    values(t1:t2,n) = ttValues;
%    t1 = find(newDates == ttDates2(1,:));
%    t2 = find(newDates == ttDates2(end,:));
%    values2(t1:t2,n) = ttValues2;
   % clean bad values for case of LEVELS
   t0 = findFirstGood(values(:,n),NaN); 
   t2 = size(values,1); 
   for t = t0+1:t2
      if isnan(values(t,n))||values(t,n)==0||isinf(values(t,n))
         values(t,n) = values(t-1,n); 
      end 
   end 
   % clean bad values for case of RETURNS
   t0 = findFirstGood(values2(:,n),NaN); 
   t2 = size(values2,1); 
   for t = t0+1:t2
      if isnan(values2(t,n))||isinf(values2(t,n))
         values2(t,n) = nanVal; 
      end 
   end 
end % for n
% Compute asset rtns, diffs according to transformation code: 
%   NOTE: indxC restores order of tickers, and re-introduces duplicates if
%   the original set of tickers contained dupes.
newTickers = bbgTickers(:,indxC); 
outStruct.header = newTickers; 
outStruct.dates = newDates; 
outStruct.lvls = values(:,indxC); 
outStruct.rtns = values2(:,indxC)/100;
end % function 
