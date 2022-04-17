function z_RiskParityXC( configFile, dtsg )

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
    
    alloc = ctx.getAllocation();
    simConfig = configureSimulation4RiskParityXC(ctx.conf.country_universe);
    riskConfig = configureRisk4RiskParity();
    if ~isempty(alloc) && simConfig.volTarget ~= alloc.standardvol 
           disp('WARNING: standard vol in simTracker does not match vol in Risk Parity production model'); ...
           disp(['their respective values are: ',num2str(alloc.standardvol),' and ',num2str(simConfig.volTarget)]);
    end % if
    
    [outputRP, outputRP2, simTrackOutput] = runCountrySpecificRiskParityXC(ctx, simConfig, riskConfig); 
    outputRP = swapFutContract(outputRP,'JB1 Comdty','BJ1 Comdty'); 
    simTrackOutput = swapFutContract(simTrackOutput,'JB1 Comdty','BJ1 Comdty'); 

    populatePerfStatsTable(outputRP.allPnl, outputRP.pnl, outputRP.assetClass, outputRP.dates, ctx.conf.oos_date);
    populateRiskParityHistAttr(ctx, simConfig, outputRP);
    
    tbl = customStruct2Table(outputRP, {'riskWts', 'wts', 'pnl', 'trades'}, {'.*'}, {});
    tbl2 = customStruct2Table(outputRP2, {'allTrades','usTrades','xmTrades','jpTrades',...
                                          'gbTrades','auTrades','caTrades','krTrades'}, {'.*'}, {});
    tbl3 = customStruct2Table(outputRP, {}, {'.*'}, {'riskWts', 'wts', 'pnl', 'trades'});

    disp([' Storing Risk Parity: ', datestr(datetime())]);
    tsrp.store_user_daily(strcat('u.d.rpxc_g7_', ctx.conf.version), tbl, true);
    tsrp.store_user_daily(strcat('u.d.rpxctrd_g7_', ctx.conf.version), tbl2, true);
    tsrp.store_user_daily(strcat('u.d.rpxcpnl_g7_', ctx.conf.version), tbl3, true);
    
    %Must run AFTER  8am SG (so Date in UTC is the same as Date in SGT)
    %Must run AFTER  6am SG (so we have Tokyo Close prices)
    %Must run BEFORE 11pm SG (so we can execute before London Close)
    idx = find(floor(simTrackOutput.dates) == floor(ctx.dtsg));
    idx2 = find(floor(outputRP.dates) == floor(simTrackOutput.dates(idx-1)));
    dtentry = ctx.getLonUtc(ctx.dtsg, 16, 0, 0);
    for h = 1:size(simTrackOutput.header,2)
        ctx.addPosition(simTrackOutput.header{h}, simTrackOutput.wts(idx,h), dtentry, dtentry, [], [], ctx.conf.id, [], outputRP.pnl(idx2,h));  %#ok<FNDSB>
    end
    disp(ctx.getOutput());
    disp([' Finished Risk Parity XC: ', datestr(datetime())]);
catch ME
    disp([' Caught Exception: ', datestr(datetime())]);
    disp(getReport(ME));
    if isdeployed
       glStatus('Risk Parity XC', strcat('ERROR: ', getReport(ME)), 3);
    end 
end

end