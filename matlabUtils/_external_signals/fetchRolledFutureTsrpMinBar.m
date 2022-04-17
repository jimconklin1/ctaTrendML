function dataStruct = fetchRolledFutureTsrpMinBar(ticker, confT, startDate, endDate)

% This function fetches min bar data from TSRP for a signle ticker. NOTE:
% we need to roll the expiries to fetch minute bar prices as a single
% time-series. NOTE: we use first_delivery for rolling expiries. 

% Inputs: 
%   futureTsrpIDs = cell array of strings; 
%   startDate = 'yyyy-mm-dd'.
%   endDate = 'yyyy-mm-dd'.
BUSDAYS_BEFORE_ROLL = -3;
if ~ischar(startDate)
    startDate = datestr(startDate,'YYYY-mm-dd');
end

if ~ischar(endDate)
    endDate = datestr(endDate,'YYYY-mm-dd');
end
roll_days = str2double(confT.roll_days);
exp_time  = confT.tz_roll_time ;
exp_tz    = confT.tz;
expiries  = tsrp.fetch_expiries(ticker);
holidays = tsrp.fetch_holidays(ticker).datenum_holiday;
busDays = busdays('1970-01-01', '2050-01-01', 1, holidays);

expiries.rolldate = datetime(min([datenum(expiries.first_delivery), datenum(expiries.last_trade)],[],2) ,'ConvertFrom', 'datenum',  'Format','yyyy-MM-dd HH:mm:ss' ,'TimeZone', 'UTC' );
expiries.isliquid = false(size(expiries.first_delivery));
for j=1 : length (expiries.first_delivery)
    expiries.isliquid(j)= ismember(expiries.product{j}(end-2) , confT.bbg_month ); % xxFxx is NOT liquid if confT.bbg_month=HMU
    ind = find( busDays <= datenum (expiries.first_delivery(j)), 1, 'last');
    rollDateExpTz = datestr (busDays(ind- roll_days -BUSDAYS_BEFORE_ROLL  ), 'yyyy-mm-dd');
    expiries.rolldate(j) = datetime(datetime ([rollDateExpTz ,' ', exp_time], 'TimeZone', exp_tz), 'TimeZone', 'UTC');
end
if strcmpi ( confT.use_config_bbg_month, '1')
    expiries = expiries(expiries.isliquid,:); % consider only liquid expiries
end

% Instead of fetching all expiries, we fetch selection of the expiries
% to make the process faster.
indexFirstExp = find(expiries.rolldate< datetime (startDate,'TimeZone', 'UTC')-days(10), 1, 'last');
indexLastExp = find(expiries.rolldate>datetime(endDate,'TimeZone', 'UTC')+days(10), 1, 'first');
tkSplit= strsplit(ticker , '.');
exps= strcat(tkSplit(1),'.',lower(expiries.product(indexFirstExp+1:indexLastExp)));
daterange = cell(size (exps));
for j=indexFirstExp+1:indexLastExp
    daterange(j-indexFirstExp) = {[expiries.rolldate(j-1),expiries.rolldate(j) ]};
end

outData = tsrp.fetch_intraday_ohlc(exps',startDate,endDate);
% outdata:
% column1: dates; for each asset, subsequent 5 columns are:
%           open, high, low, close, flagIntger
dataStruct.header = exps;
dataStruct.dates = datetime(outData(:,1),'ConvertFrom', 'datenum','TimeZone', 'UTC');
% here compute the splice factor, required to normalize historical
%   price levels across rolls
spliceRatio = ones(length(exps),1);
spliceFactor = ones(length(exps),1);
rollDateIndx = ones(length(exps),1);
for n = 1:length(exps)-1
    k1 = 1+5*(n-1)+4;
    k2 = 1+5*n+4;
    temp = find(dataStruct.dates<=daterange{n}(2),1,'last');
    if ~isempty(temp)
       rollDateIndx(n,1) = temp;
       rollPriceCurr = outData(rollDateIndx(n,1),k1);
       rollPriceNext = outData(rollDateIndx(n,1),k2);
       spliceRatio(n,1) = rollPriceNext/rollPriceCurr;
    end % if
end % for
for n = length(exps)-1:-1:1
    spliceFactor(n,1) = spliceFactor(n+1)*spliceRatio(n,1);
end % for
for n = 1:length(exps)
    k = 5*(n-1)+5;
    dateIndx = find(daterange{n}(1) <dataStruct.dates & dataStruct.dates<=daterange{n}(2));
    dataStruct.close(dateIndx,1) = spliceFactor(n,1)*outData(dateIndx,k);
    dataStruct.range(dateIndx,1) = spliceFactor(n,1)*(outData(dateIndx,k-2) - outData(dateIndx,k-1));
end % for n
dataStruct.dates = datenum (dataStruct.dates);
end % fn
