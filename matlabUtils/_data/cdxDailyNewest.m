function [nTickers, dailyRtns] = cdxDailyNewest(ctx,endDate,series,dailyRtns,StartDate)
    
    [CTickerPrcUS,CTickerSprdUS,CTickerSprdEur,CTickerSprdAus,CTickerSprdJap,CTickerSprd,CTickerGen,cdxUSprc,cdxUSsprd,cdxEur,cdxAus,cdxJap,cdxPrc,cdxSprd,CTicker,CTickerAll] = tickerSeries(series); %#ok<ASGLU>
    
    cSeries = currentSeries(ctx,CTickerAll,series,CTickerGen);
    
    CTicker = CTicker(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerGen)))'));
    CTickerGen = CTickerGen(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerGen)))'));
  
    % start date for each ticker:
    [seriesRollDt,dayRange] = cdxStartDate(ctx,CTicker,CTickerGen,CTickerAll,endDate,StartDate);
    
    % daily price
    % pull/calculate price
    disp(['Series ', strcat('s',num2str(series))]);
    disp(['Starting Pulling Daily Price ', datestr(datetime())]);
    cdxPrice = [];
    cdxSpread = [];
    % EM and HY Price NYC close
    disp(['EM & HY ', datestr(datetime())]);    
    cdxUSprc = cdxUSprc(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerPrcUS)))'));
    if ~isempty(cdxUSprc)
        CTickerPrcUS = CTickerPrcUS(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerPrcUS)))'));
        cdxPrice = GetCleanPrice(ctx,cdxUSprc,dayRange,'Asia/Singapore','America/New_York',CTickerPrcUS,cdxPrice);
        cdxSpread = prcToSprd(ctx,cdxUSprc,cdxPrice,CTickerPrcUS,cdxSpread);
    end
    
    % IG Spread NYC close
    disp(['IG ', datestr(datetime())]);       
    cdxUSsprd = cdxUSsprd(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdUS)))'));
    if ~isempty(cdxUSsprd)
        CTickerSprdUS = CTickerSprdUS(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdUS)))'));
        cdxSpread = GetCleanPrice(ctx,cdxUSsprd,dayRange,'Asia/Singapore','America/New_York',CTickerSprdUS,cdxSpread); 
        cdxPrice = sprdToPrc(ctx,cdxUSsprd,cdxSpread,CTickerSprdUS,cdxPrice);
    end
    
    % EUR Spread London close
    disp(['EUR ', datestr(datetime())]);       
    cdxEur = cdxEur(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdEur)))'));
    if ~isempty(cdxEur)
        CTickerSprdEur = CTickerSprdEur(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdEur)))'));
        cdxSpread = GetCleanPrice(ctx,cdxEur,dayRange,'Asia/Singapore','Europe/London',CTickerSprdEur,cdxSpread);
        cdxPrice = sprdToPrc(ctx,cdxEur,cdxSpread,CTickerSprdEur,cdxPrice);
    end
    
    % AUS Spread London close
    disp(['AUS ', datestr(datetime())]);       
    cdxAus = cdxAus(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdAus)))'));
    if ~isempty(cdxAus)
        CTickerSprdAus = CTickerSprdAus(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdAus)))'));
        cdxSpread = GetCleanPrice(ctx,cdxAus,dayRange,'Asia/Singapore','Australia/Sydney',CTickerSprdAus,cdxSpread);  
        cdxPrice = sprdToPrc(ctx,cdxAus,cdxSpread,CTickerSprdAus,cdxPrice);  
    end
    
    % JAP Spread London close
    disp(['JAP ', datestr(datetime())]);
    cdxJap = cdxJap(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdJap)))'));
    if ~isempty(cdxJap)
        CTickerSprdJap = CTickerSprdJap(logical(str2double(cSeries.current(ismember(cSeries.tickers,CTickerSprdJap)))'));
        cdxSpread = GetCleanPrice(ctx,cdxJap,dayRange,'Asia/Singapore','Asia/Tokyo',CTickerSprdJap,cdxSpread);  
        cdxPrice = sprdToPrc(ctx,cdxJap,cdxSpread,CTickerSprdJap,cdxPrice);
    end
    
            
    % get CDS Ticker Information, including price, last coupon date, coupon
    % in bps
      
    CTickerInfo = GetCDSInfo(ctx,CTicker,CTickerGen,cdxPrice);    
   
    % BBG accrual interest
    BAccruedInt = getAccInt(ctx,CTicker,CTickerInfo,CTickerGen,cdxPrice);
    
    % calculate diry price
    dirtyPrice = dirtyPrc(CTickerGen,cdxPrice,BAccruedInt);
    
    % calculate rtns
    dirtyPrcRtns = dtyPrcRtns(CTickerGen,dirtyPrice);
    
    % save2tsrp
    saveCdxToTSRP(CTickerAll,CTickerGen,cdxPrice,cdxSpread,BAccruedInt,dirtyPrice,dirtyPrcRtns,CTickerInfo);
    
    nTickers = fields(cdxPrice);
    
    dailyRtns.(char(strcat('S',num2str(series)))).cdxPrice = cdxPrice;
    dailyRtns.(char(strcat('S',num2str(series)))).cdxSpread = cdxSpread;
    dailyRtns.(char(strcat('S',num2str(series)))).BAccruedInt = BAccruedInt;
    dailyRtns.(char(strcat('S',num2str(series)))).dirtyPrice = dirtyPrice;
    dailyRtns.(char(strcat('S',num2str(series)))).dirtyPrcRtns = dirtyPrcRtns;
    dailyRtns.(char(strcat('S',num2str(series)))).rollDt = seriesRollDt;
    
end