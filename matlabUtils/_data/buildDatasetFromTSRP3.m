function liquidFactors = buildDatasetFromTSRP3(ctx,replAsstCnfg,assetConfigTable,startDate,endDate)
% insure date inputs are converted to character format:
if isnumeric(startDate); startDate = datestr(startDate,'yyyy-mm-dd'); end 
if isnumeric(endDate); endDate = datestr(endDate,'yyyy-mm-dd'); end 

% pull flat data from database: 
tempHeader = replAsstCnfg.assetHeader(1,:); 
temp1 = tsrp.fetch_bbg_daily_close(tempHeader, startDate, endDate); 
[tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end)); 


%%%
% temporary fix for cdx data stored in tsrp.user_daily
disp([' Starting Pulling CDS Dirty Prices for dates from ', datestr(startDate), ' to ', datestr(endDate), ' at ', datestr(datetime())]);
  
cdxTicker = SaveCDXPriceNAccruedInt(ctx);
% dateS = busdate(startDate,-1);
% dateE = busdate(endDate,-1);
cdxHeader = tempHeader;
cdxIndex = ismember(cdxHeader, cdxTicker);
for i = 1: length(cdxHeader)
    if cdxIndex(i) == 1
        % tmp = table2array(tsrp.fetch_user_daily(strcat('u.d.cdx_pricenaccrued_', lower(strrep(cdxHeader(i),' ','_'))), datestr(dateS,'yyyy-mm-dd'), datestr(dateE,'yyyy-mm-dd'),''));
        tmp = table2array(tsrp.fetch_user_daily(strcat('u.d.cdx_pricenaccrued_', lower(strrep(cdxHeader(i),' ','_'))), startDate, endDate,''));
        index = ismember(tempDates1,tmp(:,1));
        temp1(index,i) = tmp(:,3);
    end
end

disp([' Finished Pulling CDS Dirty Prices for dates from ', datestr(startDate), ' to ', datestr(endDate), ' at ', datestr(datetime())]);

%%%

temp2 = transformFlatData(replAsstCnfg.assetHeader,tempDates1,temp1,replAsstCnfg.assetTransformCode); 

% get series required for carry computations: 
tempHeader = replAsstCnfg.auxAssetHeader(1,:); 
temp3a = tsrp.fetch_bbg_daily_close(tempHeader, startDate, endDate); 
[tempDates3,temp3b] = cleanTSRPdates(temp3a(:,1),temp3a(:,2:end)); 
temp3 = alignNewDatesJC(tempDates3,temp3b,tempDates1,NaN); 

% now transform series into returns / changes, and contribute carry to the
%   computations on selected series: 
temp4 = computeReplTotalRtns(replAsstCnfg.assetHeader,assetConfigTable,temp1,temp2,replAsstCnfg.auxAssetHeader,temp3); 

%%%
% fix the CDX EM outlier on date '2014-10-06'
disp([' Starting Fixing Em data noise in "2014-10-06" ', datestr(datetime())]);

emIndex = ismember(cdxHeader, 'CDX EM CDSI GEN 5Y PRC Corp');
for i = 1: length(tempHeader)
    if emIndex(i) == 1
        if ismember(735878,tempDates1)
        temp4(tempDates1==735878,i) = 0.000458370196605218;
        end
    end
end

disp([' Finished Fixing Em data noise in "2014-10-06" ', datestr(datetime())]);
%%%

liquidFactors.header = replAsstCnfg.assetHeader; 
liquidFactors.dates = tempDates1;  
liquidFactors.levels = temp1; 
liquidFactors.flatRtns = temp2; 
liquidFactors.totRtns = temp4; 
end % fn 


% pp = javaclasspath('-dynamic');
% if sum(strcmp(pp,'C:\blp\API\blpapi3.jar'))<1
%    javaaddpath('C:\blp\API\blpapi3.jar')
% end % if
% c = blp; 
