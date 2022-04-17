function data = GetBbgHist(ConBbg, TickerName, StartDate, EndDate)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
% it as a text file (dates are hell to deal with).
%__________________________________________________________________________
%
% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
databbg = fetch(ConBbg, TickerName, ...
                'HISTORY',{'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, ...
                StartDate, EndDate, 'd');
volvwapbbg = fetch(ConBbg, TickerName, ...
                'HISTORY',{'PX_VOLUME', 'EQY_WEIGHTED_AVG_PX'}, StartDate, EndDate, 'd');            
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
data = databbg(:,2:5); % data
% clean first row
data1r = data(1,:);   data1r(isnan(data1r)) = 0; 
data(1,:) = data1r;   clear data1r
[nrows, ncols] = size(data); % Dimensions
% Clean close
for i = 2:nrows
    if isnan(data(i,4)) || data(i,4) == 0
        data(i,4) = data(i-1,4);
    end
end
% Basic clean for OHL
for j=1:3
    for i=2:nrows
        if isnan(data(i,j)) || data(i,j) == 0
            data(i,j) = data(i-1,4);
        end
    end
end
% Vlookup VWAP & Volume Clean Volume 
% (dun concateNate, vlookup to be on the safe side)
[vlup_volu, junk] = RollingVlookup(databbg, volvwapbbg, 2, 1);
clear junk
[vlup_vwap, junk] = RollingVlookup(databbg, volvwapbbg, 3, 1);
clear junk
clear  volvwapbbg
% Clean
if isnan(vlup_vwap(1)), vlup_vwap(1) = 0; end
if isnan(vlup_volu(1)), vlup_volu(1) = 0; end
for i = 2:nrows
    if isnan(vlup_volu(i,1)) || vlup_volu(i,1) == 0
        vlup_volu(i,1) = vlup_volu(i-1,1);
    end 
    if isnan(vlup_vwap(i,1)) || vlup_vwap(i,1) == 0
        vlup_vwap(i,1) = vlup_vwap(i-1,1);
    end    
end
%-- Built data array --
data = [sest , data, vlup_volu, vlup_vwap];
clear databbg datev sest vlup_vwap vlup_volu
