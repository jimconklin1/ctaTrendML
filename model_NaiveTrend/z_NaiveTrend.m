function z_NaiveTrend( configFile, dtsg )

if (~isdeployed)
   addpath 'H:\GIT\quantSignals\model_NaiveTrend';
   addpath 'H:\GIT\matlabUtils\_context';
   verbose = true;
else
   verbose = false;
end

srAddPaths();

try
    if ~exist('dtsg', 'var')
        dtsg = 'today';
    end
    ctx = ModelContext(configFile, dtsg);
    % times are in UTC fractions: 
    %        0.25 = 06:00/24:00 = Tokyo close
    %        0.667 = 16:00/24:00 or 15:00/24:00 = London close 
    %        0.875 = 21:00/24:00 or 20:00/24:00 = NY close
    nyClose = datenum(datetime(datetime ( floor(ctx.dtutc) ,'ConvertFrom', 'datenum' ,'TimeZone', 'America/New_York') + hours (16),  'TimeZone', 'UTC')); 
    lnClose = datenum(datetime(datetime ( floor(ctx.dtutc) ,'ConvertFrom', 'datenum' ,'TimeZone', 'Europe/London') + hours (16),  'TimeZone', 'UTC')); 
    tyClose = datenum(datetime(datetime ( floor(ctx.dtutc) ,'ConvertFrom', 'datenum' ,'TimeZone', 'Asia/Tokyo') + hours (15),  'TimeZone', 'UTC'));
    if ctx.dtutc>= tyClose &&  ctx.dtutc  < lnClose
       execTZ = 'postTokyoClose';
    elseif ctx.dtutc>= lnClose &&  ctx.dtutc  <  nyClose
       execTZ = 'postLondonClose';
    else
       execTZ = 'postNYClose';
    end
    
    disp([' Starting Naive Trend: ', datestr(datetime())]); 
    [portSimCombined, dataConfig] = runNaiveTrend2('combined',ctx,execTZ,verbose,'Combined');
    portSimCombined = swapFutContract(portSimCombined,'JB1 Comdty','BJ1 Comdty'); 
    portSim = prepareData4Viz(portSimCombined, dataConfig);
    portSim2 = prepareData4VizAC(portSimCombined, dataConfig);
    
    % Ad hoc reports, no need to run on a daily basis
    % Commenting out for sake of performance
    %populatePerfStatsTable(portSimCombined.totPnl, portSimCombined.pnl, strrep(portSimCombined.header, '.', ' '),...
    %    portSimCombined.dates, '2016-04-30');
    %populateNaiveTrendHistAttr(portSimCombined, ctx.conf, dataConfig);
    
    portSimCombined.header = strrep(portSimCombined.header, '.', ' ');
    tbl_combined = customStruct2Table(portSimCombined, {'wts', 'pnl', 'rawSig'}, {'wts', 'pnl', 'rawsig', 'totPnl', 'mmaPnl', 'mboPnl',...
        'mmoPnl', 'tstatPnl','targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts', 'equTrades', 'ratesTrades',...
        'cmdTrades', 'ccyTrades'}, {'wts0', 'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates'});
    tbl_portSim = customStruct2Table(portSim, {}, {'.*'}, {});
    tbl_portSim2 = customStruct2Table(portSim2, {}, {'.*'}, {});
    portSimPnl = portSimCombined;
    portSimPnl.dates = portSimPnl.pnlDates;
    tbl_combined_pnl = customStruct2Table(portSimPnl, {'pnl'}, {'pnl', 'totPnl', 'mmaPnl', 'mboPnl', 'mmoPnl','tstatPnl'},...
        {'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates', 'targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts',...
        'equTrades', 'ratesTrades', 'cmdTrades', 'ccyTrades'});
    
    disp([' Storing Naive Trend: ', datestr(datetime())]);
    tsrp.store_user_daily(strcat('u.d.naive_trend_combined_', ctx.conf.version), tbl_combined(end-60:end,:), false);
    tsrp.store_user_daily(strcat('u.d.naive_trend_', ctx.conf.version), tbl_portSim(end-60:end,:), false);
    tsrp.store_user_daily(strcat('u.d.naive_trend_ac_', ctx.conf.version), tbl_portSim2(end-60:end,:), false);
    tsrp.store_user_daily(strcat('u.d.naivetrend_pnl_', ctx.conf.version), tbl_combined_pnl(end-60:end,:), false);
    

    simTrackerConfig = configureSimulation4countrySpecificTrend;
    idx = find(floor(portSimCombined.dates) == floor(ctx.dtsg));
    for h = 1:size(portSimCombined.header,2)
        hd = portSimCombined.header{h};
        if strncmpi(portSimCombined.header{h}, 'fx ', 2)
            hd = strcat(upper(portSimCombined.header{h}(end-5:end)), ' Curncy');
        end
        
        if ismember(hd,simTrackerConfig.assetHeader)
            dtentrystart = fix(ctx.dtutc) + simTrackerConfig.entryStartUtcs(hd);
            dtentryend = fix(ctx.dtutc) + simTrackerConfig.entryEndUtcs(hd);
        else
            dtentrystart = fix(ctx.dtutc) + simTrackerConfig.entryStartUtcs('USDJPY Curncy');
            dtentryend = fix(ctx.dtutc) + simTrackerConfig.entryEndUtcs('USDJPY Curncy');
        end
        
        %if execution timeframe is in the past (model runs in the afternoon and want to trade in the morning), move a day forward
        if dtentrystart < ctx.dtutc
            dtentrystart = dtentrystart + 1;
            dtentryend = dtentryend + 1;
        end

        %if execution start falls on Saturday, move to Monday
        if weekday(dtentrystart) == 7
            dtentrystart = dtentrystart + 2;
            dtentryend = dtentryend + 2;
        end

        %if execution start falls on Sunday, move to Monday
        if weekday(dtentrystart) == 7
            dtentrystart = dtentrystart + 1;
            dtentryend = dtentryend + 1;
        end

        ctx.addPosition(hd, portSimCombined.wts(idx,h), dtentrystart, dtentryend, [], [], ctx.conf.id, [], portSimCombined.pnl(idx,h)); 
    end
    disp(ctx.getOutput());
    disp([' Finished Naive Trend: ', datestr(datetime())]);
    
catch ME
    disp([' Caught Exception: ', datestr(datetime())]);
    disp(getReport(ME));
    glStatus(' Naive Trend', strcat('ERROR: ', getReport(ME)), 3);
end

end