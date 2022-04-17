function outData = fetchAlignedBbgDataFromTSRP(assetID,dataType,startDate,endDate,alignOption) 

% This function fetches daily Bloomberg data from the TSRP Riak and aligns
%  them according to a couple of options, either by the dates bbg returns 
%  with the first ticker in assetID, ('firstColumn') or by the union of all 
%  available data ('union').

% Inputs: 
%   assetID = cell array of strings 
%   dataType = 'level','price' (the same) or 'return'
%   startDate = 'yyyy-mm-dd'
%   endDate = 'yyyy-mm-dd'
%   alignOption = 'union' or 'firstColumn'

if nargin < 5 || isempty(alignOption)
   alignOption = 'union';
end 
if nargin < 4 || isempty(endDate)
   endDate = datestr(today(),'yyyy-mm-dd');
end 
if nargin < 3 || isempty(startDate)
   startDate = '2006-01-03';
end 
if nargin < 2 || isempty(dataType)
   alignOption = 'price';
end 

if strcmpi(dataType,'level')
   alignOption = 'price';
end 
% -- Add path for functions --
if (~isdeployed)
   addpath 'H:\GIT\matlabUtils\JG\MyFunctions\';
   addpath 'H:\GIT\matlabUtils\JG\PortfolioOptimization\';
   addpath 'H:\GIT\matlabUtils\_data\';
   addpath 'H:\GIT\mtsrp\';
end

switch alignOption
   case 'firstColumn' 
      VarName = assetID(1);
      data = tsrp.fetch_bbg_daily_close(VarName, startDate, endDate);
      T = size(data,1);
      N = length(assetID); 
      dates = data(:,1);
      % Pre-allocate variable
      tempData = NaN(T,N);
      tempData(:,1) = data(:,2); 
      % -- get data --
      for n = 2:N
          data = tsrp.fetch_bbg_daily_close(assetID(n), startDate, endDate);
          if ~isempty(data)
             cJunk = VlookupExcel(dates, data(:,1), data(:,2), 'NaNtoZero');
             tempData(:,n) = cJunk;
             clear cJunk
          else 
             disp(['WARNING: data from ',assetID{n},' was not found in TSRP bbg data cache.'])
          end % if
      end 
      outData.header = assetID;
      outData.dates = dates;
      if strcmpi(dataType,'price')
         outData.close = tempData;
      else % 'return'
         newData = calcFlatData2rtns(assetID,dates,tempData,ones(1,N),'zeros');  
         outData.close = newData;
      end 
   case 'union' 
      if size(assetID,1) > size(assetID,2); assetID = assetID'; end
      tempData = tsrp.fetch_bbg_daily_close(assetID, startDate, endDate);
      outData.header = assetID;
      outData.dates = tempData(:,1);
         if strcmpi(dataType,'price')
            outData.close = tempData;
         else % 'return'
            newData = calcFlatData2rtns(assetID,dates,tempData,ones(1,N),'zeros');  
            outData.close = newData;
         end % if 
end % switch

end % fn
