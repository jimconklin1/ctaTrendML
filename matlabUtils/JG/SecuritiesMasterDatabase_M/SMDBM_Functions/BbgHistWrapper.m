function data = BbgHistWrapper(ConBbg, TickerName, OHLCOption, VwapOption, VolumeOption, OpenInterestOption, StartDate, EndDate, method)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
% it as a text file (dates are hell to deal with). The issue is that
% Bloomberg API cannot retrieve more than 4 fields per request.  I need to
% break the request in many sub-requests and then concatenate the data.
% Input:
%   - OHLCOption=1 (close only)
%   - OHLCOption=4 (Open, High, Low, Close) ..not the best way for sure
%   - VwapOption=1 or 0, Get or Do Not get VWAP
%   - VolumeOption=1 or 0, Get or Do Not get Volume
%   - OpenInterestOption=1 or 0, Get or Do Not get Open Interest
%__________________________________________________________________________
%
% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
% -- OHLC --
if OHLCOption == 1
    switch method
        case {'daily', 'd'} 
            databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'daily');
        case {'weekly', 'w'}        
            databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'daily');
        case {'monthly', 'm'}        
            databbg = history(ConBbg, TickerName, {'PX_LAST'}, StartDate, EndDate, 'daily');
    end
elseif OHLCOption == 4   
    switch method
        case {'daily', 'd'} 
            databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
        case {'weekly', 'w'}        
            databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
        case {'monthly', 'm'}        
            databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, StartDate, EndDate, 'daily');
    end
end
%
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
%
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
% -- Open Interest --
if OpenInterestOption == 1
    switch method
        case {'daily', 'd'}    
            OpenIntBbg = history(ConBbg, TickerName, {'OPEN_INT'}, StartDate, EndDate, 'daily');  
        case {'weekly', 'w'}            
            OpenIntBbg = history(ConBbg, TickerName, {'OPEN_INT'}, StartDate, EndDate, 'weekly');
        case {'monthly', 'm'}            
            OpenIntBbg = history(ConBbg, TickerName, {'OPEN_INT'}, StartDate, EndDate, 'monthly');
    end
end
%
% -- Clean Dates & Change to Human Readable Format --
DateHRFOption=1;
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
% -- Clean Data --
if OHLCOption==1
    data = databbg(:,2);
elseif OHLCOption==4
    data = databbg(:,2:5); 
end
%
% clean first row
data1r = data(1,:);   data1r(isnan(data1r)) = 0; 
data(1,:) = data1r;   clear data1r
[nrows, ncols] = size(data); % Dimensions

if OHLCOption==1
    for i = 2:nrows
        if isnan(data(i,1)) || data(i,1) == 0
            data(i,1) = data(i-1,1);
        end
    end
elseif OHLCOption==4
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
% -- Open Interest --
if OpenInterestOption == 1
    [vlookup_OpenIntBbg, junk] = RollingVlookup(databbg, OpenIntBbg, 2, 1);
    clear junk OpenIntBbg 
% Clean
    if isnan(vlookup_OpenIntBbg(1)), vlookup_OpenIntBbg(1) = 0; end
    for i = 2:nrows
        if isnan(vlookup_OpenIntBbg(i,1)) || vlookup_OpenIntBbg(i,1) == 0
            vlookup_OpenIntBbg(i,1) = vlookup_OpenIntBbg(i-1,1);
        end   
    end        
end

%-- Built data array --
if VwapOption == 0 && VolumeOption == 0 && OpenInterestOption == 0
    
    data = [sest , dateBbg , data];   

elseif VwapOption == 1 && VolumeOption == 1 && OpenInterestOption == 0
    
    data = [sest , dateBbg , data, vlookup_vwap, vlookup_volume];
    
elseif VwapOption == 1 && VolumeOption == 1 && OpenInterestOption == 1
    
    data = [sest , dateBbg , data, vlookup_vwap, vlookup_volume, vlookup_OpenIntBbg]; 
    
elseif VwapOption == 1 && VolumeOption == 0 && OpenInterestOption == 0
    
    data = [sest , dateBbg , data, vlookup_vwap];
    
elseif VwapOption == 0 && VolumeOption == 1 && OpenInterestOption == 0
    
    data = [sest , dateBbg , data, vlookup_volume];  
    
elseif VwapOption == 0 && VolumeOption == 0 && OpenInterestOption == 1
    
    data = [sest , dateBbg , data, vlookup_OpenIntBbg];     
    
elseif VwapOption == 0 && VolumeOption == 1 && OpenInterestOption == 1
    
    data = [sest , dateBbg , data, vlookup_volume, vlookup_OpenIntBbg];     
    
end
clear databbg datev sest dateBbg vlookup_vwap vlookup_volume