function z_cdxData(configFile,startDate,endDate)

if (~isdeployed)
    addpath 'H:\GIT\quantSignals_amy\CDS_Pricer';
    addpath 'H:\GIT\matlabUtils\_context';
    addpath 'H:\GIT\mtsrp\';
end

srAddPaths();

try
    
    if ~exist('configFile','var')
        configFile = 'prod.conf'; 
    end
    
    ctx = srSetup(configFile);
    disp(['Start Pulling CDX Data: ', datestr(datetime())]);
    
    %startDate = busdate('2017-01-01',1);
    if ~exist('endDate','var')
        endDate = today; 
    else 
        endDate = datenum(endDate);
    end 
    
    if ~exist('startDate','var')
        if  ~strcmp(configFile,'prod.conf')
            startDate = nan; 
        else
            startDate = today - 10;
        end
    else
        startDate = datenum(startDate);
    end 
    
    [currentSeries,seriesInfo] = getLatestSeries(ctx);
    
    % pull cdx data for concurrent series
    dailyRtns = [];
    series = 17:(currentSeries-1);
    for s = 1:length(series)
        dailyRtns = cdxDaily(ctx,endDate,series(s),dailyRtns,startDate);
    end
    
    % get the latest tickers
    latestTickers = fields(dailyRtns.(char(strcat('S',num2str(series(end))))).cdxPrice);
    
    % pull cdx data for the newest series (some tickers may not have)
    seriesNew = currentSeries;
    for s = 1:length(seriesNew)
        [newestTickers,dailyRtns] = cdxDailyNewest(ctx,endDate,seriesNew(s),dailyRtns,startDate);
    end
    
    % get the newest tickers
    tsrpTickers = tsrpTicker(latestTickers,newestTickers);
    
    % write historical data to TSRP in non-production mode
    if ~strcmp(configFile,'prod.conf')
        spliceGenHis(CTickerAll,seriesInfo);
    end
    
    % write the most recent series in Gen series
    spliceGen(tsrpTickers,startDate,endDate);
    
    disp(['Finish Pulling CDX Data: ', datestr(datetime())]);
    
catch ME
    disp([' Caught Exception: ', datestr(datetime())]);
    disp(getReport(ME));
    glStatus('CDX Returns', strcat('ERROR: ', getReport(ME)), 3);
    throw(ME);
end

end