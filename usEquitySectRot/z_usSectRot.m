function z_usSectRot( configFile )

% -- Add path for functions --
if (~isdeployed)
    addpath 'H:\GIT\quantSignals\macroTradingModels\usEquitySectRot\';
    addpath 'H:\GIT\matlabUtils\_context'
    addpath 'H:\GIT\mtsrp\';
end

srAddPaths();

try
    % -- step 1: --
    configFile = 'usSectRot.conf';
    ctx = srSetup(configFile); 
    configData = usSectRotConfiguration('bbgSapi'); % configuration
    
    % -- step 2: upload the data from Tsrp or Bbg Sapi or Bbg Local--
    dataSet = uploadData(configData);

    % -- step 3: compute the factors --
    factors = computeFactors(dataSet);

    % -- step 4: run the models for each day of the week, aggregate & prepare output --mrfVolAdj
    [output,bestSectorT, shT, wgthT, drhT] = usSectRot(configData,dataSet,factors);

    % -- Step 6: store in tsrp & message -- 
    disp([' US Sector Rotation: ', datestr(datetime())])
    tsrp.store_user_daily(strcat('u.d.usSectRot_signals', '_', ctx.conf.version), shT, true);
    tsrp.store_user_daily(strcat('u.d.spTf_wgt', '_', ctx.conf.version), wgthT, true);
    tsrp.store_user_daily(strcat('u.d.spTf_dailyReturn', '_', ctx.conf.version), drhT, true);
    disp([' US Sector Rotation: ', datestr(datetime())])

    
catch ME
    disp([' Caught Exeception: ', datestr(datetime())])
    disp(getReport(ME));
    glStatus('usSectorRotation', strcat('ERROR: ', getReport(ME)), 3);
end
    
end