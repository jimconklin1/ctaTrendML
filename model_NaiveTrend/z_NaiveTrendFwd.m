function z_NaiveTrendFwd( configFile, dtsg )
% Identical logic as Naive Trend, but generates a forward path of
%   positions based on current information, and forward up and forward down
%   price perturbations.

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
    ctx.conf.forwardPosn = true;
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
    
    disp([' Starting Naive Trend Shocks: ', datestr(datetime())]); 
    runNaiveTrendFwd('combined',ctx,execTZ,verbose,'Combined');
    %[portSimCombined, dataConfig] = runNaiveTrendFwd('combined',ctx,execTZ,verbose,'Combined');
    %portSimCombined = swapFutContract(portSimCombined,'JB1 Comdty','BJ1 Comdty'); 
    
    %filename = ['\\gama.com\Singapore\Common\quantProduction\docs\modelDocs\naiveTrend\pertubation\pertubation_',datestr(today,'ddmmmyyyy'),'.xlsx'];
    %signalMatch = checkFwdSignals(dataConfig,portSimCombined);
    %writetable(signalMatch,filename,'Sheet','signalCheck','WriteRowNames',true);
    %portSim = prepareData4Viz(portSimCombined, dataConfig);
    
    % Ad hoc reports, no need to run on a daily basis
    % Commenting out for sake of performance
    %populatePerfStatsTable(portSimCombined.totPnl, portSimCombined.pnl, strrep(portSimCombined.header, '.', ' '),...
    %    portSimCombined.dates, '2016-04-30');
    %populateNaiveTrendHistAttr(portSimCombined, ctx.conf, dataConfig);
    
    %{
    portSimCombined.header = strrep(portSimCombined.header, '.', ' ');
    tbl_combined = customStruct2Table(portSimCombined, {'wts', 'pnl', 'rawSig'}, {'wts', 'pnl', 'rawsig', 'totPnl', 'mmaPnl', 'mboPnl',...
        'mmoPnl', 'tstatPnl','targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts', 'equTrades', 'ratesTrades',...
        'cmdTrades', 'ccyTrades'}, {'wts0', 'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates'});
    
    portSimCombinedu.header = strrep(portSimCombinedu.header, '.', ' ');
    tbl_combinedu = customStruct2Table(portSimCombinedu, {'wts', 'pnl', 'rawSig'}, {'wts', 'pnl', 'rawsig', 'totPnl', 'mmaPnl', 'mboPnl',...
        'mmoPnl', 'tstatPnl','targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts', 'equTrades', 'ratesTrades',...
        'cmdTrades', 'ccyTrades'}, {'wts0', 'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates'});
    
    portSimCombinedd.header = strrep(portSimCombinedd.header, '.', ' ');
    tbl_combinedd = customStruct2Table(portSimCombinedd, {'wts', 'pnl', 'rawSig'}, {'wts', 'pnl', 'rawsig', 'totPnl', 'mmaPnl', 'mboPnl',...
        'mmoPnl', 'tstatPnl','targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts', 'equTrades', 'ratesTrades',...
        'cmdTrades', 'ccyTrades'}, {'wts0', 'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates'});
    %}
    
    %tbl_portSim = customStruct2Table(portSim, {}, {'.*'}, {});
    %portSimPnl = portSimCombined;
    %portSimPnl.dates = portSimPnl.pnlDates;
    %tbl_combined_pnl = customStruct2Table(portSimPnl, {'pnl'}, {'pnl', 'totPnl', 'mmaPnl', 'mboPnl', 'mmoPnl','tstatPnl'},...
    %    {'equPnl', 'ratesPnl', 'cmdPnl', 'ccyPnl', 'pnlDates', 'targRisk', 'equWts', 'ratesWts', 'cmdWts', 'ccyWts',...
    %   'equTrades', 'ratesTrades', 'cmdTrades', 'ccyTrades'});
    
    %disp([' Storing Naive Trend: ', datestr(datetime())]);
    %tsrp.store_user_daily(strcat('u.d.naive_trend_combined_', ctx.conf.version), tbl_combined(end-60:end,:), false);
    %tsrp.store_user_daily(strcat('u.d.naive_trend_', ctx.conf.version), tbl_portSim(end-60:end,:), false);
    %tsrp.store_user_daily(strcat('u.d.naivetrend_pnl_', ctx.conf.version), tbl_combined_pnl(end-60:end,:), false);
    %{
    idx = find(round(portSimCombined.dates) == floor(ctx.dtsg));
    for h = 1 : size(portSimCombined.header, 2)
        hd = portSimCombined.header{h};
        if strncmpi(portSimCombined.header{h}, 'fx ', 3)
            hd = strcat(upper(portSimCombined.header{h}(end-5:end)), ' Curncy');
            dtentrystart = ctx.getLonUtc(ctx.dtsg, 15, 45, 0);
            dtentryend = ctx.getLonUtc(ctx.dtsg, 16, 0, 0);
        else
            dtentrystart = fix(ctx.dtutc) + dataConfig.entryStartUtcs(hd);
            dtentryend = fix(ctx.dtutc) + dataConfig.entryEndUtcs(hd);
            if dtentrystart < ctx.dtutc
                dtentrystart = dtentrystart + 1;
                dtentryend = dtentryend + 1;
            end                    
        end
        ctx.addPosition(hd, portSimCombined.wts(idx, h), dtentrystart, dtentryend, [], [], ctx.conf.id, [], portSimCombined.pnl(idx-1,h)); 
    end
    disp(ctx.getOutput());
    %}
    disp([' Finished Naive Trend Shocks: ', datestr(datetime())]);
    
catch ME
    disp([' Caught Exception: ', datestr(datetime())]);
    disp(getReport(ME));
    % glStatus(' Naive Trend Shocks', strcat('ERROR: ', getReport(ME)), 3);
end

end