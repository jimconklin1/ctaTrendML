function [outdates, indx] = eomonth(indates,n,opt)

% This function takes any date, and converts it to the date at the end of the n-th
% month ahead.  eomonth only operates on numeric dates. 
% e.g., 30june2001=eomonth(15may2001,1).
% e.g., 30june2001=eomonth(15june2001,0).

% opt = 'lastCalendarDate' or 'lastInputDate'
if nargin < 3
   opt = 'lastCalendarDate'; 
end 
if nargin < 2 || isempty(n)
   n = 0; 
end 
outdates = indates;
indx = [];
for i = 1:length(indates)
    indate = indates(i);
    % dd = day(indate);
    mm = month(indate);
    yy = year(indate);
    mm = mm + round(n);
    if mm>12
        mm=mm-12;
        yy=yy+1;
    end % if mm>13
    leapyears=1500+4*(1:300);
    if ismember(mm,[1 3 5 7 8 10 12]','rows')
        dd=31;
    elseif ismember(mm,[4 6 9 11]','rows')
        dd=30;
    elseif ismember(yy,leapyears)
        dd=29;
    else
        dd=28;
    end
    dTemp = datenum(yy,mm,dd);
    outdates(i) = datenum(yy,mm,dd);
    temp = find(indates == dTemp,1); 
    while isempty(temp)
       dTemp = dTemp -1;
       temp = find(indates == dTemp,1); 
    end % while 
    indx = [indx,temp]; %#ok
end % for i
indx = unique(indx); 
if strcmpi(opt,'lastInputDate')
   outdates = indates(indx);
end % if
end % fn