function data = GetBbgHist(ConBbg, TickerName, VwapOption, VolumeOption, StartDate, EndDate, method)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
% it as a text file (dates are hell to deal with).
%__________________________________________________________________________
%
% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
% -- OHLC --
switch method
    case {'daily', 'd'} 
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
    case {'weekly', 'w'}        
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
    case {'monthly', 'm'}        
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
end
% -- VWAP --
if VwapOption==1
    switch method
        case {'daily', 'd'}     
            vwapBbg = history(ConBbg, TickerName, {'EQY_WEIGHTED_AVG_PX'}, StartDate, EndDate, 'daily');  
        case {'weekly', 'w'}        
            vwapBbg = history(ConBbg, TickerName, {'EQY_WEIGHTED_AVG_PX'}, StartDate, EndDate, 'weekly'); 
        case {'monthly', 'm'} 
            vwapBbg = history(ConBbg, TickerName, {'EQY_WEIGHTED_AVG_PX'}, StartDate, EndDate, 'monthly'); 
    end
end
% -- Volume --
if VolumeOption == 1
    switch method
        case {'daily', 'd'}    
            volumeBbg = history(ConBbg, TickerName, {'PX_VOLUME'}, StartDate, EndDate, 'daily');  
        case {'weekly', 'w'}            
            volumeBbg = history(ConBbg, TickerName, {'PX_VOLUME'}, StartDate, EndDate, 'weekly');
        case {'monthly', 'm'}            
            volumeBbg = history(ConBbg, TickerName, {'PX_VOLUME'}, StartDate, EndDate, 'monthly');
    end
end
%
% -- Clean Dates & Change to Human Readable Format --
datev = databbg(:,1); % date
dateBbg = datev; % memo date
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
% Vlookup VWAP & Volume Clean Volume (dun concateNate, vlookup to be on the safe side)
% -- VWAP --
if VwapOption==1
    [vlookup_vwap, junk] = RollingVlookup(databbg, vwapBbg, 2, 1);
    clear junk vwapBbg  
    % Clean
    if isnan(vlookup_vwap(1)), vlookup_vwap(1) = 0; end
    for i = 2:nrows
        if isnan(vlookup_vwap(i,1)) || vlookup_vwap(i,1) == 0
            vlookup_vwap(i,1) = vlookup_vwap(i-1,1);
        end    
    end    
end
% -- Volume --
if VolumeOption == 1
    [vlookup_volume, junk] = RollingVlookup(databbg, volumeBbg, 2, 1);
    clear junk volumeBbg 
% Clean
    if isnan(vlookup_volume(1)), vlookup_volume(1) = 0; end
    for i = 2:nrows
        if isnan(vlookup_volume(i,1)) || vlookup_volume(i,1) == 0
            vlookup_volume(i,1) = vlookup_volume(i-1,1);
        end   
    end        
end

%-- Built data array --
if VwapOption==1 && VolumeOption == 1
    data = [sest , dateBbg , data, vlookup_vwap, vlookup_volume];
elseif VwapOption==1 && VolumeOption == 0
    data = [sest , dateBbg , data, vlookup_vwap];
elseif VwapOption==0 && VolumeOption == 1
    data = [sest , dateBbg , data, vlookup_volume];    
elseif VwapOption==0 && VolumeOption == 0
    data = [sest , dateBbg , data];       
end
clear databbg datev sest dateBbg vlookup_vwap vlookup_volume
