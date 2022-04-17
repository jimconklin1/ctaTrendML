function data = BbgHistSingleTS(ConBbg, TickerName, FieldName, StartDate, EndDate, periodParameter)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
%__________________________________________________________________________
%
% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
if strcmp(periodParameter, 'daily') || strcmp(periodParameter, 'd')
    databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
elseif strcmp(periodParameter, 'weekly') || strcmp(periodParameter, 'w')       
    databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
elseif strcmp(periodParameter, 'monthly') || strcmp(periodParameter, 'm')          
    databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
end
%
% -- Clean Dates & Change to Human Readable Format --
DateHRFOption=2;
if DateHRFOption==1
    dateBbg = databbg(:,1); % date   
    sest = year(databbg(:,1))*10000 + month(databbg(:,1))*100 + day(databbg(:,1));
elseif DateHRFOption==2
    datev = databbg(:,1); % date
    dateBbg = datev; % memo date
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
data = databbg(:,2); % Clean Data
% clean first row
data1r = data(1,:);   data1r(isnan(data1r)) = 0; 
data(1,:) = data1r;   clear data1r
[nrows, ncols] = size(data); % Dimensions
for i = 2:nrows
    if isnan(data(i,1)) || data(i,1) == 0, data(i,1) = data(i-1,1); end
end
%
data = [sest , dateBbg , data];   % Built data array
