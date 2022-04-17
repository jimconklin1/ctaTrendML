function assetData = extendDatasetForward(assetData,volVec,noPeriods,grossPerturbation)
% assetData must have 2 fields ('dates', and 'header') and at least on of
%    'close','value', or 'rtns'.
% volVec is a vector of (daily) standard deviations (vols) of returns as of
%    the last day of the sample
% noPeriods is an integer and is the number of periods you want to project
%    forward your signals 
% grossPerturbation is in daily standard deviation units.  That is, if
%    noPeriods = 5 and grossPerturbation = 3, the return for each day of
%    extended data will be 3/5ths of a daily standard deviation.
T = size(assetData.dates,1);
N = size(assetData.header,2);
temp = ones(noPeriods+1,1);
temp(1,:) = assetData.dates(end); 
for i = 2:noPeriods+1
   temp(i,:) = busdate(temp(i-1,:),1); 
end % for
assetData.endDates0 = repmat(assetData.dates(end,:),[1,size(assetData.header,2)]);
assetData.dates = [assetData.dates; temp(2:end,:)]; 
assetData.endDates = repmat(assetData.dates(end,:),[1,size(assetData.header,2)]);
temp = (grossPerturbation/noPeriods)*volVec; 
temp = repmat(temp,[noPeriods,1]); 
if isfield(assetData,'rtns')
   assetData.rtns = [assetData.rtns; temp];
elseif isfield(assetData,'close')
   assetData.close = [assetData.close; temp];
elseif isfield(assetData,'value')
   assetData.value = [assetData.value; temp];
end % if 

if isfield(assetData,'range')
   temp = repmat(assetData.range(end,:),[noPeriods,1]);
   assetData.range = [assetData.range; temp];
end % if 

end % fn
