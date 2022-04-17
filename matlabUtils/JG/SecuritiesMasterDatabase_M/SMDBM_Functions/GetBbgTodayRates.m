function  [data, AssetTraded] = GetBbgTodayRates(ConBbg, TickerName, PointDate, method)
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
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, PointDate, PointDate, 'daily');
    case {'weekly', 'w'}        
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, PointDate, PointDate, 'weekly');
    case {'monthly', 'm'}        
        databbg = history(ConBbg, TickerName, {'PX_OPEN', 'PX_HIGH' ,'PX_LOW','PX_LAST'}, PointDate, PointDate, 'monthly');
end

% -- Check Dimensions of databbg in order to check whether asset traded --            
[nrowsdatabbg, ncolsdatabbg] = size(databbg);

if ncolsdatabbg > 2
    %
    % -- Inform if Asset Traded or not --
    AssetTraded = 1;
    % -- Dowlnoad VWAP & Volume --
    switch method
        case {'daily', 'd'}    
            volvwapbbg = history(ConBbg, TickerName, {'PX_VOLUME', 'EQY_WEIGHTED_AVG_PX'}, PointDate, PointDate, 'daily');     
        case {'weekly', 'w'}  
            volvwapbbg = history(ConBbg, TickerName, {'PX_VOLUME', 'EQY_WEIGHTED_AVG_PX'}, PointDate, PointDate, 'weekly');             
        case {'monthly', 'm'} 
            volvwapbbg = history(ConBbg, TickerName, {'PX_VOLUME', 'EQY_WEIGHTED_AVG_PX'}, PointDate, PointDate, 'monthly');  
    end
    % -- Clean Dates & Change to Human Readable Format --
    datev = databbg(1,1); % date
    if iscell(datev(1)), datev = cell2mat(datev); end
    t=datev;
    t_year = year(t); t_month = month(t); t_day = day(t);
    for n = 1:1
        t_year_n = num2str(t_year(n));
        t_month_n = num2str(t_month(n)); [Nn,Mn] = size(t_month_n);
        if Mn == 1, t_month_n = strcat('0', t_month_n); end
        t_day_n = num2str(t_day(n)); [Nn,Mn] = size(t_day_n);
        if Mn == 1, t_day_n = strcat('0', t_day_n); end
        sest_n = strcat(t_year_n, t_month_n, t_day_n);
        sest(n) = str2double(sest_n);
    end
    % -- Clean Data --
    data = databbg(:,2:5); % data
    % clean first row
    data1r = data(1,:);   data1r(isnan(data1r)) = 0; 
    data(1,:) = data1r;   clear data1r
    [nrows, ncols] = size(data); % Dimensions
    %-- Built data array --
    data = [sest , data];
    clear databbg datev sest
else    
    % -- Inform if Asset Traded or not --
    AssetTraded = 0;
    %-- Built data array --
    t = PointDate;
    % Check if Month has been entered as double digit (04, and not 4 for
    % instance)
    if t(2) == '/'
        % Get month
        t_month = strcat('0', t(1));   
        % Get day
        if t(4) == '/'
            strcat('0', t(3)); % day
            t_year = t(5:8); % year
        elseif t(4) ~= '/'
            t_day = t(3:4); % day
            t_year = t(6:9); % year
        end        
    elseif t(2) ~= '/' 
        % Get month
        t_month = t(1:2);
        % Get day
        if t(5) == '/'
            t_day = strcat('0', t(4));  % day
            t_year = t(6:9); % year
        elseif t(5) ~= '/' 
            t_day = t(4:5); % day
            t_year = t(7:10); % year
        end
    end
    t = strcat(t_year, t_month, t_day);
    sest = str2double(t);
    data = [sest, 0,0,0,0,0,0,0];
end
    

