function z_RiskParityDD( configFile, dtsg )

if (~isdeployed)
    addpath 'H:\GIT\quantSignals\model_RiskParity';
    addpath 'H:\GIT\matlabUtils\_context';
end

srAddPaths();

try
    if ~exist('dtsg','var')
        dtsg = 'today';
    end
    ctx = ModelContext(configFile, dtsg);
    
    disp([' Starting Risk Parity: ', datestr(datetime())]);
    
    simConfig = configureSimulation4countrySpecificRiskParity(ctx.conf.country_universe);
    riskConfig = configureRisk4RiskParity2(simConfig);
    
    [dataStruct,lonDataStruct,dataStruct2] = buildRiskParityData(ctx,simConfig,'US');
    omega = calcRiskMatrix2(dataStruct,riskConfig); 
    annPortVol = repmat(simConfig.volTarget,[size(dataStruct.close,1),1]);

    [outputRP, outputRP2, simTrackOutput] = runCountrySpecificRiskParity2(ctx, dataStruct, lonDataStruct, omega, annPortVol, simConfig);
    portStruct = outputRP;
    portConfig.header = simConfig.assetHeader;
    portConfig.TC = simConfig.TC;
    portConfig.ddOpt = true; 
    portConfig.minTrade = 0.0025;
    portConfig.targVol = 0.08;
    dd.A = 10; %16, 10
    dd.maxDD = 0.06; 
    dd.lambda = 0.06; % HW mark decay rate 
    dd.mu = 0.08; 
    dd.sigma = 0.08; 
    dd.minVol = 0.02; 
    portConfig.dd = dd;
    dataSet = dataStruct;
    dataSet.holidays = tsrp.fetch_holidays('SP1 Index');
    portSimDD = calcDDandPnL3(portConfig, dataSet, portStruct); 
%         portSim = portSimAlladj;
%        figure(13); plot(portSim.dates,[calcCum(sum(portSim.pnl,2),1),calcCum(sum(portSimDD.pnlDD,2),1)]); grid; datetick('x','mmmyyyy')   
%        figure(14); plot(portSim.dates,[calcCum(sum(portSimDD.pnlDD,2),1)]); grid; datetick('x','mmmyyyy')   
%        figure(15); plot(portSim.dates,portSim.ddrawdown); 
%        figure(16); plot(portSim.dates,portSim.ddVol);
%        disp(['SRs are ',num2str(16*nanmean(sum(portSimDD.pnl,2))/nanstd(sum(portSimDD.pnl,2))),' for straight, ',num2str(16*nanmean(sum(portSimDD.pnlDD,2))/nanstd(sum(portSimDD.pnlDD,2))),' for DD'])

%    innovStruct = runInnovationDecomposition(lonDataStruct,dataStruct2); 
    outputRP = swapFutContract(outputRP,'JB1 Comdty','BJ1 Comdty'); 
    simTrackOutput = swapFutContract(simTrackOutput,'JB1 Comdty','BJ1 Comdty'); 

    populatePerfStatsTable(outputRP.allPnl, outputRP.pnl, outputRP.assetClass, outputRP.dates, ctx.conf.oos_date);
    populateRiskParityHistAttr(ctx, simConfig, outputRP);
    
    tbl = customStruct2Table(outputRP, {'riskWts', 'wts', 'pnl', 'trades'}, {'.*'}, {});
    tbl2 = customStruct2Table(outputRP2, {'allTrades','usTrades','xmTrades','jpTrades',...
                                         'gbTrades','auTrades','caTrades','krTrades'}, {'.*'}, {});
    tbl3 = customStruct2Table(outputRP, {}, {'.*'}, {'riskWts', 'wts', 'pnl', 'trades'});

    disp([' Storing Risk Parity: ', datestr(datetime())]);
    tsrp.store_user_daily(strcat('u.d.rp_g6_', ctx.conf.version), tbl, true);
    tsrp.store_user_daily(strcat('u.d.rptrd_g6_', ctx.conf.version), tbl2, true);
    tsrp.store_user_daily(strcat('u.d.rppnl_g6_', ctx.conf.version), tbl3, true);
    
    %Must run AFTER  8am SG (so Date in UTC is the same as Date in SGT)
    %Must run AFTER  6am SG (so we have Tokyo Close prices)
    %Must run BEFORE 11pm SG (so we can execute before London Close)
    idx = find(floor(simTrackOutput.dates) == floor(ctx.dtsg));
    idx2 = find(floor(outputRP.dates) == floor(simTrackOutput.dates(idx-1)));    
    for h = 1:size(simTrackOutput.header,2)
        dtentrystart = fix(ctx.dtutc) + simConfig.entryStartUtcs(simTrackOutput.header{h});
        dtentryend = fix(ctx.dtutc) + simConfig.entryEndUtcs(simTrackOutput.header{h});
        
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
        
        ctx.addPosition(simTrackOutput.header{h}, simTrackOutput.wts(idx,h), dtentrystart, dtentryend, [], [], ctx.conf.id, [], outputRP.pnl(idx2,h)); 
    end
    disp(ctx.getOutput());
    disp([' Finished Risk Parity: ', datestr(datetime())]);
catch ME
    disp([' Caught Exception: ', datestr(datetime())]);
    disp(getReport(ME));
    glStatus('Risk Parity', strcat('ERROR: ', getReport(ME)), 3);
end

end