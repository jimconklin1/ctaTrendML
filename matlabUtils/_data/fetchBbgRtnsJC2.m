function [badTickers,outStruct] = fetchBbgRtnsJC2(bbgTickers,startDate,endDate,c,freq,transformCode)

% parse inputs: 
if nargin < 6 || isempty(transformCode)
    transformCode = ones(1,length(bbgTickers)); 
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

if nargin < 3 || isempty(endDate)
    endDate = today(); 
end

if size(bbgTickers,1) > size(bbgTickers,2)
   bbgTickers = bbgTickers';
end % if

% deal with duplicate tickers:
[bbgTickers,~,indxC] = unique(bbgTickers);

% set paths, define vars:
newDates = makeStandardDates(startDate,endDate);
str1 = datestr(startDate,'mm/dd/yyyy');
str2 = datestr(endDate,'mm/dd/yyyy');
tempData = history(c,bbgTickers,{'PX_LAST'},str1,str2,[freq,{'non_trading_weekdays'}]);
N = length(bbgTickers);
badIndx = [];

% Now align returns: 
for n = 1:N
    if isstruct(tempData) && ischar(tempData{n})
       badIndx = [badIndx,n]; %#ok
    elseif ~isstruct(tempData) && isnumeric(tempData)
       tempData = {tempData}; 
    end
end
badTickers = bbgTickers(:,badIndx);
goodIndx = setdiff(1:N,badIndx); 
indxC = setdiffJC(indxC,badIndx); 
M = length(goodIndx); 
ttDates = tempData{goodIndx(1)}(:,1);
values = zeros(length(newDates),M); 
for n = goodIndx
   ttDates = tempData{n}(:,1);
   dIndx = ismember(ttDates,newDates);
   ttDates = ttDates(dIndx,:);
   ttValues = tempData{n}(:,2);
   ttValues = ttValues(dIndx,:);
   t1 = find(newDates == ttDates(1,:));
   t2 = find(newDates == ttDates(end,:));
   values(t1:t2,n) = ttValues;
   t0 = findFirstGood(values(:,n),NaN); 
   for t = t0+1:t2
      if isnan(values(t,n))||values(t,n)==0||isinf(values(t,n))
         values(t,n) = values(t-1,n); 
      end 
   end 
end % for n
% compute asset rtns, diffs according to transformation code: 
%   NOTE: indxC restores order of tickers, and re-introduces duplicates if
%   the original set of tickers contained dupes.
newTickers = bbgTickers(:,indxC); 
outStruct.header = newTickers; 
outStruct.dates = ttDates; 

outStruct.lvls = values(:,indxC); % bbg gives returns in percentage terms 
temp1 = values(2:end,indxC)./values(1:end-1,indxC) - 1;
temp2 = (values(2:end,indxC) - values(1:end-1,indxC))/100;
indx = transformCode == 2;
temp1(:,indx) = temp2(:,indx); % replace returns with %-age rate changes on rate instruments
temp1(isnan(temp1)) = 0;
outStruct.rtns = [zeros(1,size(values(:,indxC),2)); temp1]; 
end % function 
