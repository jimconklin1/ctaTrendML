addpath 'H:\GIT\matlabUtils\_data'; 
addpath 'H:\GIT\matlabUtils\_context'; 
addpath 'H:\GIT\mtsrp\'; 
modelName = 'RiskParity'; 
%modelName = 'NaiveTrend'; 

outFileName1 = ['S:\quantProduction\simTrackerReports\',modelName,'\attributionTable1_',datestr(today(),'yyyymmdd'),'.csv'];
outFileName2 = ['S:\quantProduction\simTrackerReports\',modelName,'\attributionTable2_',datestr(today(),'yyyymmdd'),'.csv'];
outFileName3 = ['S:\quantProduction\simTrackerReports\',modelName,'\attributionTable3_',datestr(today(),'yyyymmdd'),'.csv'];
outFileName4 = ['S:\quantProduction\simTrackerReports\',modelName,'\attributionTable4_',datestr(today(),'yyyymmdd'),'.csv'];

DB_database = 'quant_strategies_trading_activity'; 
DB_username = 'simtrac_model'; 
DB_password = 'amzorth34mf'; 
DB_driver = 'com.mysql.jdbc.Driver'; 
DB_url = 'jdbc:mysql://10.60.51.92:3306/quant_strategies_trading_activity'; 
ctx.dbConn = database(DB_database, DB_username, DB_password, DB_driver, DB_url); 

startDate = datenum('05-sep-2016'); 
endDate = datenum('30-sep-2016'); 
dates = makeStandardDates(startDate,endDate); 
T = length(dates); 
attribFields = {'modelPnl','modelTC','modelWts','actPnl','actTC','actNtnlWts'}; 
volMult = zeros(T,1); 
riskCapital = zeros(T,1); 
% pull in data from mySQL: 
for t = 1:length(dates) 
   closeDate = datestr(dates(t),'yyyy-mm-dd'); 
   % call stored proc; data: date, model_id, assetclass, country, assetID, model_pnl_bps, model_tc_bps, model_weight, 
   %                         aum, vol_multiplier, actual_pnl_bps, actual_tc_bps, actual_notnl, reportGroup, region
   attributionCellMatrix = fetch(ctx.dbConn, ['call get_attribution_data(''',closeDate,''',''',modelName,''')']); 
   if ~isempty(attributionCellMatrix)
      if ~exist('assetIDs','var')
         assetIDs = attributionCellMatrix(:,5);
         assetClass = attributionCellMatrix(:,14);
         region = attributionCellMatrix(:,15);
         N = length(assetIDs); 
         attribCube = zeros(T,N,length(attribFields)); 
      end % if
      temp = attributionCellMatrix(:,[6:8,11:13]);
      attribCube(t,:,:) =  cell2mat(temp); 
      riskCapital(t) = attributionCellMatrix{1,9};
      volMult(t) = attributionCellMatrix{1,10};
      attribCube(t,:,end) =  attribCube(t,:,end)/riskCapital(t); 
      attribCube(t,:,end-2:end) = attribCube(t,:,end-2:end)/volMult(t);
   end % if 
end % for 

% for t = 1:length(dates)
%    % Maps each string in cell array cellstruct to its location in the 
%    %  cell array assetIDS: 
%    if ~isempty(cellStruct{t}) 
%       k1 = mapStrings(cellStruct{t}(:,5)',assetIDs,false); 
%       allPnL(t,1) = nansum(cell2mat(cellStruct{t}(:,11))); 
%       temp = cellStruct{t}(:,[6:8,11:13]); 
%       attribCube(t,k1,:) =  cell2mat(temp); 
%       riskCapital(t) = cellStruct{t}{1,9}; 
%       volMult(t) = cellStruct{t}{1,10}; 
%       % convert actual notional amount into a comparable weight:
%       attribCube(t,:,end) = attribCube(t,:,end)/riskCapital(t); 
%       attribCube(t,:,end-2:end) = attribCube(t,:,end-2:end)/volMult(t); 
%    end % if 
% end % for 

% plot all-in PnL from normalized system performance vs. simulation:
temp = squeeze(nansum(attribCube(:,:,[1,4]),2)); 
plot(dates,temp); datetick('x','ddmmm','keepticks'); grid; legend({'simulation','actual'})
plot(dates,calcCum(temp,0)); datetick('x','ddmmm','keepticks'); grid; legend({'simulation','actual'})

% now create a new attribution cube with five categories: 
%   total pnl diff; pnlDiff due to marks; pnlDiff due to rounding; pnlDiff due
%   to TCs; resid
attribFields2 = {'totalDiff','roundDiff','tcDiff','resid'}; 
attribCube2 = zeros(T,length(assetIDs),length(attribFields2)); 
% note: all units are in bps:
for t = 1:T 
   attribCube2(t,:,1) = nansum([attribCube(t,:,1); -attribCube(t,:,4)],1); 
   simAsstRtns = attribCube(t,:,1)./attribCube(t,:,3); 
   actAsstRtns = attribCube(t,:,4)./attribCube(t,:,6); 
   attribCube2(t,:,2) = simAsstRtns.*(attribCube(t,:,3)- attribCube(t,:,6)); 
   attribCube2(t,:,3) = attribCube(t,:,2)- attribCube(t,:,5); 
   attribCube2(t,:,4) = attribCube2(t,:,1) - nansum(attribCube2(t,:,2:4),3); 
end % for 

% Create a full-month table for PnL attribution by asset groupings:
v = [squeeze(nansum(attribCube(:,:,[1,4]),1)),squeeze(nansum(attribCube2,1))]; 

attribTable1 = table(assetClass,region,v(:,1),v(:,2),v(:,3),v(:,4),v(:,5),v(:,6),'VariableNames',[{'assetClass','region','PnL','simPnL'},attribFields2],'RowNames',assetIDs'); 
attribTable1 = sortrows(attribTable1,{'assetClass','region'}); 
assetIDs3 = attribTable1.Properties.RowNames; 
indx = find(strcmp(attribTable1.assetClass,'Commodities'));
temp2 = sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1); 
indx = find(strcmp(attribTable1.region,'Energy')); 
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),...
              attribTable1.roundDiff(indx),attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
indx = find(strcmp(attribTable1.region,'Ags')); 
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),...
              attribTable1.roundDiff(indx),attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
indx = find(strcmp(attribTable1.region,'Metals')); 
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),...
              attribTable1.roundDiff(indx),attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% All equities
indx = find(strcmp(attribTable1.assetClass,'Equities DM')|strcmp(attribTable1.assetClass,'Equities EM'));
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% DM Equities
bool1 = strcmp(attribTable1.assetClass,'Equities DM');
indx = find(bool1);
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% EM Equities
bool1 = strcmp(attribTable1.assetClass,'Equities EM');
indx = find(bool1);
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% All FX
indx = find(strcmp(attribTable1.assetClass,'FX'));
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% DM FX
bool1 = (strcmp(attribTable1.Properties.RowNames,'USDCAD Curncy')|strcmp(attribTable1.Properties.RowNames,'AUDUSD Curncy')|...
         strcmp(attribTable1.Properties.RowNames,'NZDUSD Curncy')|strcmp(attribTable1.Properties.RowNames,'USDJPY Curncy')|strcmp(attribTable1.Properties.RowNames,'USDSGD Curncy')|...
         strcmp(attribTable1.Properties.RowNames,'EURUSD Curncy')|strcmp(attribTable1.Properties.RowNames,'GBPUSD Curncy')|strcmp(attribTable1.Properties.RowNames,'USDCHF Curncy')|...
         strcmp(attribTable1.Properties.RowNames,'USDCHF Curncy')); 
bool2 = strcmp(attribTable1.assetClass,'FX') & bool1; 
indx = find(bool2); 
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
                   attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% EM FX
bool2 = strcmp(attribTable1.assetClass,'FX') & ~bool1; 
indx = find(bool2); 
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
                  attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 

% All Rates
indx = find(strcmp(attribTable1.assetClass,'Rates'));
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 
% Rates bonds:
bool1 = (strcmp(attribTable1.Properties.RowNames,'CN1 Comdty')|strcmp(attribTable1.Properties.RowNames,'TY1 Comdty')|...
         strcmp(attribTable1.Properties.RowNames,'BJ1 Comdty')|strcmp(attribTable1.Properties.RowNames,'JB1 Comdty')|...
         strcmp(attribTable1.Properties.RowNames,'KAA1 Comdty')|strcmp(attribTable1.Properties.RowNames,'RX1 Comdty')|...
         strcmp(attribTable1.Properties.RowNames,'XM1 Comdty')|strcmp(attribTable1.Properties.RowNames,'G 1 Comdty'));
indx = find(bool1);
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)],1)]; 

% Rates short:
bool2 = strcmp(attribTable1.assetClass,'Rates') & ~bool1;
indx = find(bool2);
temp2 = [temp2; sum([attribTable1.PnL(indx),attribTable1.simPnL(indx),attribTable1.totalDiff(indx),attribTable1.roundDiff(indx),...
            attribTable1.tcDiff(indx),attribTable1.resid(indx)])]; 

% Total:
temp2 = [temp2; sum([attribTable1.PnL,attribTable1.simPnL,attribTable1.totalDiff,attribTable1.roundDiff,...
                   attribTable1.tcDiff,attribTable1.resid])]; 

% Create a table of full-month attribution by individual assets:
tempRow = {'Commodities','Commods: Energy','Commods: Ags','Commods: Metals','Equities','Equities: DM','Equities: EM','FX',...
           'FX: DM','FX: EM','Rates','Rates: bonds','Rates: short','Total'};
tempCol = {'SimulatedPnL','ActualPnL','Diff_SimVsAct','Diff_posRound','Diff_TCs','Diff_resid'}; 
attribTable2 = table(temp2(:,1),temp2(:,2),temp2(:,3),temp2(:,4),temp2(:,5),temp2(:,6),'VariableNames',tempCol,'RowNames',tempRow'); 
temp3 = [[attribTable1.PnL,attribTable1.simPnL,attribTable1.totalDiff,attribTable1.roundDiff,...
                   attribTable1.tcDiff,attribTable1.resid];
          sum([attribTable1.PnL,attribTable1.simPnL,attribTable1.totalDiff,attribTable1.roundDiff,...
                   attribTable1.tcDiff,attribTable1.resid])];
attribTable3 = table(temp3(:,1),temp3(:,2),temp3(:,3),temp3(:,4),temp3(:,5),temp3(:,6),'VariableNames',tempCol,'RowNames',[assetIDs3;{'Total'}]); 

% Create a table of full-month attribution by dates:
tempRow = mat2cell(datestr(dates,'dd-mmm-yyyy'),ones(1,T),11);
tempCol = {'SimulatedPnL','ActualPnL','Diff_SimVsAct','Diff_posRound','Diff_TCs','Diff_resid'}; 
v2 = [squeeze(nansum(attribCube(:,:,[1,4]),2)),squeeze(nansum(attribCube2,2))]; 
v2 = [v2; nansum(v2)];
attribTable4 = table(v2(:,1),v2(:,2),v2(:,3),v2(:,4),v2(:,5),v2(:,6),'VariableNames',tempCol,'RowNames',[tempRow;{'Total'}]); 

writetable(attribTable1,outFileName1,'WriteRowNames',true,'FileType','spreadsheet')
writetable(attribTable2,outFileName2,'WriteRowNames',true,'FileType','spreadsheet')
writetable(attribTable3,outFileName3,'WriteRowNames',true,'FileType','spreadsheet')
writetable(attribTable4,outFileName4,'WriteRowNames',true,'FileType','spreadsheet')

% diagnostics: for asset with large differences, plot PnLs over time:
selectedAsset = 'HI1 Index';
n = find(strcmp(assetIDs,selectedAsset));
if ~isempty(n)
    temp = squeeze(attribCube(:,n,[1,4]));
    figure(1); plot(dates,calcCum(temp,0)); datetick('x','ddmmm','keepticks'); grid; legend({[selectedAsset,' simulation PnL'],[selectedAsset,' actual PnL']})
    temp = squeeze(attribCube(:,n,[3,6]));
    figure(2); plot(dates,temp); datetick('x','ddmmm','keepticks'); grid; legend({[selectedAsset,' simulation wts'],[selectedAsset,' actual wts']})
end % if

% The following is for pricing out-of-sample simTracker positions:
% assetTCs =  [2.0, 2.0, 4.0, 2.0, ...
%              2.0, 2.0, 2.0, 2.0, ...
%              3.5, 3.5, 3.5, 3.5, 3.5, ...
%              3.5, 3.5, 3.5, 3.5, ...           % 17 equities
%              1.5, 1.5, 1.5, 1.5, 2.0, 2.0, 2.0, ...
%              1.5, 1.5, 1.5, 1.5,           ... % 11 rates
%              3.0, 3.0, 3.0, 3.0, 3.0, ...
%              4.0, 2.0, 3.0, 3.0, 3.0, ...      % 10 comdty
%              1.0, 2.0, 1.0, 1.0, 1.5, ...
%              1.0, 2.5, 3.0, 5.0, ...
%              3.0, 3.0, 3.0, 5.0, 5.0, ...
%              10.0, 10.0, 6.0, 4.0, 5.0, ...
%              10.0, 5.0, 5.0, 5.0, 5.0, ...
%              5.0, 5.0, 5.0, 5.0, 2.5, ...       % 29 ccys;
%              2.0];         % BJ1 Comdty; 68 assets in total

% code for pricing oos wts:
         
% temp1 = squeeze(sum(attribCube(:,:,[1,4]),2)); 
% plot(dates,temp1); 
% oosTrend.assetIDs = assetIDs;
% oosTrend.assetIDs([1,10:12,29,15,38:60]) = {'fx.audusd','fx.eurczk','fx.eurhuf','fx.eurusd','fx.gbpusd','fx.nzdusd',...
%                                             'fx.usdbrl','fx.usdcad','fx.usdchf','fx.usdclp','fx.usdcnh','fx.usdcop','fx.usdidr',...
%                                             'fx.usdils','fx.usdinr','fx.usdjpy','fx.usdkrw','fx.usdmxn','fx.usdmyr','fx.usdnok',...
%                                             'fx.usdphp','fx.usdpln','fx.usdrub','fx.usdsek','fx.usdsgd','fx.usdthb','fx.usdtry',...
%                                             'fx.usdtwd','fx.usdzar'}; 
% oosTrend.wts = squeeze(attribCube(:,:,3));
% lonDataStruct = fetchAlignedTSRPdata(oosTrend.assetIDs,'returns','daily','london',datestr(dates(1),'yyyy-mm-dd'),datestr(busdate(dates(end),1),'yyyy-mm-dd'));
% lonDataStructCcy = fetchAlignedTSRPdata(oosTrend.assetIDs,'returns','daily','london',datestr(dates(1),'yyyy-mm-dd'),datestr(busdate(dates(end),1),'yyyy-mm-dd'),1);
% lonDataStruct.close(:,[1,10:12,29,15,38:60])=lonDataStructCcy.close(:,[1,10:12,29,15,38:60]);
% oosTrend.pnl = zeros(size(oosTrend.wts));
% oosTrend.pnlTC = zeros(size(oosTrend.wts));
% oosTrend.pnl(2:end-1,:) = oosTrend.wts(1:end-2,:).*lonDataStruct.close(2:end,:);
% oosTrend.pnlTC(2:end-1,:) = abs(oosTrend.wts(1:end-2,:)-oosTrend.wts(2:end-1,:)).*repmat(assetTCs,[size(oosTrend.wts(2:end-1,:),1),1])/10000;
