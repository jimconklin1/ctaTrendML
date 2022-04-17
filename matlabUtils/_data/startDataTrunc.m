function assetData2 = startDataTrunc(assetData,config,t0,t1)
if nargin < 3 || isempty(t0)
    t0 =  find(assetData.dates>=config.simStartDate,1);
end
if nargin < 4 || isempty(t1)
    t1 = min([length(assetData.dates), find(floor(assetData.dates)<=floor(config.simEndDate),1,'last')]);
end
assetData2 = assetData;
assetData2.dates = assetData.dates(t0:t1,:);
assetData2.startDates = repmat(assetData.dates(t0),size(assetData.startDates));
assetData2.endDates = repmat(assetData.dates(t1),size(assetData.endDates));
if isfield(assetData2,'values')
   assetData2.values = assetData.values(t0:t1,:);
end 
if isfield(assetData2,'close')
   assetData2.close = assetData.close(t0:t1,:);
end 
if isfield(assetData2,'range')
   assetData2.range = assetData.range(t0:t1,:);
end 
if isfield(assetData2,'rtns')
   assetData2.rtns = assetData.rtns(t0:t1,:);
end 
end % fn