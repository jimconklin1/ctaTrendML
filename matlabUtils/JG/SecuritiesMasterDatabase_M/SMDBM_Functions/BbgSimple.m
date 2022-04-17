function data = BbgSimple(ConBbg, TickerName, FieldName, StartDate, EndDate, method)
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

switch method
    case {'daily', 'd'} 
        databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
    case {'weekly', 'w'}        
        databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
    case {'monthly', 'm'}        
        databbg = history(ConBbg, TickerName, FieldName, StartDate, EndDate, 'daily');
end

% -- Clean Dates & Change to Human Readable Format --
dateBbg = databbg(:,1); % date   
dateBbgHrf = year(databbg(:,1))*10000 + month(databbg(:,1))*100 + day(databbg(:,1));
%
% -- Clean Data --
data = databbg(:,2);
%
% clean first row
data1r = data(1,:);   data1r(isnan(data1r)) = 0; 
data(1,:) = data1r;   clear data1r
[nrows, ncols] = size(data); % Dimensions

for i = 2:nrows
    if isnan(data(i,1)) || data(i,1) == 0
        data(i,1) = data(i-1,1);
    end
end

%-- Built data array --
data = [dateBbgHrf, dateBbg , data];   
