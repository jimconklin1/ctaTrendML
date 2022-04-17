function priceData = fetchCurrPxData4trend(dataConfig,sigSession) %,bbgConn)

% NOTE: TZ suppressed... use dataConfig to get the right price level by asset
if nargin<3 || isempty(sigSession)
    sigSession = 'TK';
end 
switch sigSession
    case 'TK'
       signalSnap = dataConfig.assetSessionSelect.postTK; 
    case 'LN'
       signalSnap = dataConfig.assetSessionSelect.postLN; 
    case 'NY'
       signalSnap = dataConfig.assetSessionSelect.postNY; 
end % switch

indxTK = find(strcmp(signalSnap,'TK'));
indxLN = find(strcmp(signalSnap,'LN'));
indxNY = find(strcmp(signalSnap,'NY'));

indxFx = mapStrings(dataConfig.ccy.header,dataConfig.assetIDs,false);
indxFut = setdiff(1:length(dataConfig.assetIDs),indxFx);
% indx = mapStrings(subset,univ,allowZeros)
% indxCo = mapStrings(dataConfig.comdty.header,dataConfig.assetIDs,false);
% indxEq = mapStrings(dataConfig.equity.header,dataConfig.assetIDs,false);
% indxRt = mapStrings(dataConfig.rates.header,dataConfig.assetIDs,false);

indxFutTK = intersect(indxFut,indxTK);
indxFutLN = intersect(indxFut,indxLN);
indxFutNY = intersect(indxFut,indxNY);
indxFxTK = intersect(indxFx,indxTK);
indxFxLN = intersect(indxFx,indxLN);
indxFxNY = intersect(indxFx,indxNY);

if ~isempty(indxFutTK)
   futTKdataConfig.header = dataConfig.assetIDs(indxFutTK);
   futTKdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFutTK)]);
   futTKdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFutTK)]);
   futTKdataConfig.pricingClose = 'Tokyo'; %, 'London', 'NY' 
   futTKdataConfig.signalClose = 'Tokyo';% , 'London', 'NY' 
   futTKprice = getDailyPriceData(futTKdataConfig,'signal');
end % if

if ~isempty(indxFutLN)
   futLNdataConfig.header = dataConfig.assetIDs(indxFutLN);
   futLNdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFutLN)]);
   futLNdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFutLN)]);
   futLNdataConfig.pricingClose = 'London'; 
   futLNdataConfig.signalClose = 'London';
   futLNprice = getDailyPriceData(futLNdataConfig,'signal');
end % if

if ~isempty(indxFutNY)
   futNYdataConfig.header = dataConfig.assetIDs(indxFutNY);
   futNYdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFutNY)]);
   futNYdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFutNY)]);
   futNYdataConfig.pricingClose = 'NY'; %, 'London', 'NY' 
   futNYdataConfig.signalClose = 'NY';% , 'London', 'NY' 
   futNYprice = getDailyPriceData(futNYdataConfig,'signal');
end % if

if ~isempty(indxFxTK)
   fxTKdataConfig.header = dataConfig.assetIDs(indxFxTK);
   fxTKdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFxTK)]);
   fxTKdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFxTK)]);
   fxTKdataConfig.pricingClose = 'Tokyo'; % 'London', 'NY' 
   fxTKdataConfig.signalClose = 'Tokyo'; % 'London', 'NY' 
   fxTKprice = getDailyPriceData(fxTKdataConfig,'signal');
end % if 

if ~isempty(indxFxLN)
   fxLNdataConfig.header = dataConfig.assetIDs(indxFxLN);
   fxLNdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFxLN)]);
   fxLNdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFxLN)]);
   fxLNdataConfig.pricingClose = 'London'; % 'London', 'NY' 
   fxLNdataConfig.signalClose = 'London';% 'London', 'NY' 
   fxLNprice = getDailyPriceData(fxLNdataConfig,'signal');
end % if

if ~isempty(indxFxNY)
   fxNYdataConfig.header = dataConfig.assetIDs(indxFxNY);
   fxNYdataConfig.startDates = repmat(dataConfig.startDate,[1,length(indxFxNY)]);
   fxNYdataConfig.endDates = repmat(dataConfig.endDate,[1,length(indxFxNY)]);
   fxNYdataConfig.pricingClose = 'NY'; %, 'London', 'NY' 
   fxNYdataConfig.signalClose = 'NY';% , 'London', 'NY' 
   fxNYprice = getDailyPriceData(fxNYdataConfig,'signal');
end % if

priceData.header = dataConfig.assetIDs; 
priceData.dates = dataConfig.endDate; 
temp = zeros(1,length(dataConfig.assetIDs)); 
if ~isempty(indxFutTK); temp(1,indxFutTK) = futTKprice.close(end,:); end
if ~isempty(indxFutLN); temp(1,indxFutLN) = futLNprice.close(end,:); end
if ~isempty(indxFutNY); temp(1,indxFutNY) = futNYprice.close(end,:); end
if ~isempty(indxFxTK); temp(1,indxFxTK) = fxTKprice.close(end,:); end
if ~isempty(indxFxLN); temp(1,indxFxLN) = fxLNprice.close(end,:); end
if ~isempty(indxFxNY); temp(1,indxFxNY) = fxNYprice.close(end,:); end
priceData.close = temp;

end % fn
