function data = GetBbgCloseHist(ConBbg, TickerName, StartDate, EndDate, method)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
% it as a text file (dates are hell to deal with).
%__________________________________________________________________________
%
% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
switch method
    case {'daily', 'd'}
        databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'daily');
    case {'weekly', 'w'}
        databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'weekly');
    case {'monthly', 'm'}    
        databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'monthly');
end        
%
% -- Clean Dates & Change to Human Readable Format --
datev = databbg(:,1); % date
OptionFormatDate=1;
if OptionFormatDate == 1
    nrows=length(datev); sest=zeros(nrows,1);
    if iscell(datev(1)), datev = cell2mat(datev); end
    t=datev;
    t_year = year(t); t_month = month(t); t_day = day(t);
    for n = 1:nrows
        t_year_n = num2str(t_year(n));
        t_month_n = num2str(t_month(n)); [Nn,Mn] = size(t_month_n);
        if Mn == 1, t_month_n = strcat('0', t_month_n); end
        t_day_n = num2str(t_day(n)); [Nn,Mn] = size(t_day_n);
        if Mn == 1, t_day_n = strcat('0', t_day_n); end
        sest_n = strcat(t_year_n, t_month_n, t_day_n);
        sest(n) = str2double(sest_n);
    end
end
%
% -- Clean Data --
data = databbg(:,2); % data
% clean first row
if isnan(data(1,:)), data(1,:)=0; end
[nrows, ncols] = size(data); % Dimensions
% Clean close
for i = 2:nrows
    if isnan(data(i,1)) || data(i,1) == 0
        data(i,1) = data(i-1,1);
    end
end

%-- Built data array --
data = [sest , data];
clear databbg datev sest 
