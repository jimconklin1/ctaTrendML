function erpb = z_ERPB(config)

PubEqPath.addLibPath('_data', '_date');

if nargin < 1 || isempty(config)
    config.indexId = 'SPX Index';
    config.oosDates = 6 * 7; % SPX fundamental date is 6 weeks after last business date of each calendar quarter
    config.dataStartDate = '01/01/1997';
    config.dataEndDate = '06/30/2020';
    
    % config.erpbMethod = 'analytical';
    % config.nomGrwth = 0.04;
    % config.nonDivPO2earn = 0.47;
    % config.calcStartDate = '01/01/2018';
    % config.calcEndDate = datestr(today - weekday(today) - 2, 'mm/dd/yyyy');
    % config.caclFreq = 'weekly';
    
    % config.erpbMethod = 'estimation';
    % config.calcStartDate = '01/01/2008';
     
    config.erpbMethod = 'perturbation';
    config.calcStartDate = '01/01/2008';
end

if strcmp(config.erpbMethod, 'analytical')
    erpb = calcAnalyticalERPB(config);
elseif strcmp(config.erpbMethod, 'estimation')
    bbgFundData = getBbgFundData(config);  % data fields are: {'DataDate', 'OOSDate', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EBITDA', 'RETURN_COM_EQY', 'REVENUE_PER_SH'}
    estimateDivParm(config, bbgFundData);
    estimateBbkParm(config, bbgFundData);
elseif strcmp(config.erpbMethod, 'perturbation')
    bbgFundData = getBbgFundData(config); % data fields are: {'DataDate', 'OOSDate', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EBITDA', 'RETURN_COM_EQY', 'REVENUE_PER_SH'}
    ebitdaEst = getBbgEstimate(config.calcStartDate, today, 'BEST_EBITDA', 'weekly');
    roeEst = getBbgEstimate(config.calcStartDate, today, 'BEST_ROE', 'weekly');
    bbgData = getBbgData(config.calcStartDate, today, 'weekly'); % fields: {'CalcDate', 'PX_LAST'}
    zeroRates = getZeroRates(config.calcStartDate, today, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'}
    
    divForecast = calcDivForecast(bbgFundData, ebitdaEst);
    bbkForecast = calcBbkForecast(bbgFundData, ebitdaEst, roeEst);
    
    erpb = calcPerturbationERPB(zeroRates, bbgData, divForecast, bbkForecast);
end

end