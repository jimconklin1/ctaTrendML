function data = BbgEcoWrapper(ConBbg, TickerName, dateBenchNum, ...
                              lagRelease, OverideRelDate, ...
                              Transform, TransformParameters, ...
                              StartDate, EndDate, method)
%
%__________________________________________________________________________
%
% This function download Bloomberg economic data and create a clean vector
% of economic released dates based upon the trading days of a benchmark
% instrument.
%
% -- Input --
% ticker name, start and end date
% a vector of daily benchmark date in numeric format (originally within the 
% function, but not a good idea if many time series need to be downloaded 
% for the same benchmark)
%
% -- Output --
% data(:,1:2) are the dates of the "state" of the economy in 2 different
% formats
% data(:,3) is the data
% data(:,4) is the observatoin date, i.e., the economic released date
% (cleaned in the sense it tallies with the day the market was open)
% test
%StartDate='01/01/1980';EndDate='09/16/2015';dataRelDate=2;TickerName='CPI YOY Index' ;lagRelease=20;SumRollOption=0;SumRollOptionWindow=4;
%__________________________________________________________________________
%

% -- Dowload Bllomberg (cannot dowload more than 4 fields in a formula) --
switch method
    case {'daily', 'd'} 
        databbg = history(ConBbg, TickerName, {'PX_LAST', 'ECO_RELEASE_DT'}, StartDate, EndDate, 'daily');
    case {'weekly', 'w'}        
        databbg = history(ConBbg, TickerName, {'PX_LAST', 'ECO_RELEASE_DT'}, StartDate, EndDate, 'weekly');
    case {'monthly', 'm'}        
        databbg = history(ConBbg, TickerName, {'PX_LAST', 'ECO_RELEASE_DT'}, StartDate, EndDate, 'monthly');
end

% -- Clean Data --
data = databbg(:,2);
nrows = size(data,1);
% Check last row
if isnan(data(nrows))
    data(nrows)=data(nrows-1);
end

% -- Transform the data if needed (for eg, current account) --
if strcmp(Transform,'noTransform')
    data = data;
elseif strcmp(Transform,'rollingSum') || strcmp(Transform,'RollingSum')
    datas = zeros(size(data));
    for i=TransformParameters(1,1):nrows
        datas(i) = nansum(data(i-TransformParameters(1,1)+1:i));
    end
    data=datas;
elseif strcmp(Transform,'roc') || strcmp(Transform,'ROC') || strcmp(Transform,'rateOfChange') || strcmp(Transform,'RateOfChange')
    data = Delta(data,'roc',TransformParameters(1,1));   
end

% -- Extract date benchmark
%databbgBench = history(ConBbg, BenchAsset, {'PX_LAST'}, StartDate, EndDate, 'daily');
%dateBench = databbgBench(:,1); 
rowsBench = size(dateBenchNum,1);
%
% -- Clean Dates & Change to Human Readable Format --
dateBbg = databbg(:,1); % date   
% dateBbgLag = nan(nrows,1);
% for i=1:nrows-lagRelease
%     dateBbgLag(i) = dateBbg(i+lagRelease);
% end
dateBbgHrf = year(databbg(:,1))*10000 + month(databbg(:,1))*100 + day(databbg(:,1));

% -- Change the Bloomberg format for Eco release date to Matlab Format --
ecoRelDtNaN = isnan(databbg(:,3));
nbNaN = sum(ecoRelDtNaN);
dnum = NaN(nrows,1);
if strcmp(OverideRelDate,'OverrideRelDate') || strcmp(OverideRelDate,'override') || strcmp(OverideRelDate,'Override') ...
        || strcmp(OverideRelDate,'OverRide') || strcmp(OverideRelDate,'overRide') 
    for i=1:nrows
        dnum(i) = dateBbg(i) + lagRelease;
    end
elseif strcmp(OverideRelDate,'NoOverRide') || strcmp(OverideRelDate,'noOverRide') || strcmp(OverideRelDate,'nooverRide') 
    if nbNaN < nrows
        for i=1:nrows
            d=databbg(i,3);
            if ~isnan(d) && d ~= 0
                dstr=num2str(d);
                dYr=dstr(1:4);dMth=dstr(5:6);dDay=dstr(7:8);
                dstr1 = strcat(dYr,'-',dMth,'-',dDay);
                dnum(i) = datenum(dstr1);
            else
                dnum(i) = dateBbg(i) + lagRelease; 
            end 
        end
    else % Apply across the board lag
        for i=1:nrows
            dnum(i) = dateBbg(i) + lagRelease;
        end
    end
end
%dnumHrf = year(dnum)*10000 + month(dnum)*100 + day(dnum);

% -- Maybe the eco time series is longer or shorter than the benchmark, so
% let s find out --
% IF isnan(startRowInBench(1,1)), it means eco time series longer
startMonthTS = month(databbg(1,1));
startYearTS = year(databbg(1,1));
startRowInBench = nan(1,1);
for i=2:rowsBench 
    if month(dateBenchNum(i-1)) == startMonthTS && year(dateBenchNum(i-1)) == startYearTS && ...
          month(dateBenchNum(i)) ~= startMonthTS   
      startRowInBench(1,1) = i;
      break
    end
end
% if is the case find when the benchmark "starts" in the eco release date
% startRowInTS = nan(1,1);
% if isnan(startRowInBench(1,1))
%     startMonthBench = month(dateBench(1,1));
%     startYearBench = year(dateBench(1,1));
%     for i=2:nrows
%         if month(dateBbg(i-1)) == startMonthBench && year(dateBbg(i-1)) == startYearBench && ...
%               month(dateBbg(i)) ~= startMonthBench   
%           startRowInTS(1,1) = i;
%           break
%         end
%     end
% end    
  
% -- Now extract a date at which the market was open to get a proper
% "market-based" eco release date
ecRelDate = nan(nrows,1);
if isnan(startRowInBench(1,1))
    initilRow = 1;
else
    initilRow = startRowInBench(1,1);
end

for i=1:nrows
    DirtyDate = dnum(i); % Dirty Eco release date (dirty means not sure it is a day when market traded)
    % The release date given by Bloomberg might not be present in the
    % benchmark date, so let s increment up to maxIter days
    maxIter = 10;
    for qqq = 0:maxIter
        DirtyDate = DirtyDate + qqq;
        for uuu =initilRow:rowsBench
            if DirtyDate == dateBenchNum(uuu)
                ecRelDate(i) = dateBenchNum(uuu);
                initilRow = i;
            end
        end
    end
end

%-- Built data array --
data = [dateBbgHrf, dateBbg, data, ecRelDate];   
