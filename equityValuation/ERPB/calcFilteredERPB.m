function [erpb,oTable] = calcFilteredERPB(eqTicker, startDate, endDate, calcFreq, cfFreq, rateOption, rateData, forecastCF,fundData,K)

% eqTicker = 'SPX Index';
% ratesTicker = 'USGG10YR Index';
% startDate = '1990-01-01';
% endDate = '2020-12-31';
% freq = 'yearly';
% fundData = dataTable pulled from 

if nargin < 4 || isempty(calcFreq)
   calcFreq = 'weekly';
end 

if nargin < 5 || isempty(cfFreq)
   cfFreq = 'quarterly';
end 

if exist('c')~=1 %#ok<EXIST>
   c = blp;
end

if nargin < 5 || isempty(rateOption)
   rateOption = 'zeroCurve';
end 

if istable(forecastCF)
   temp = table2array(forecastCF);
   forecast.dates = temp(:,1);
   forecast.values = temp(:,2:end);
else
   forecast.dates = forecastCF(:,1); 
   forecast.values = forecastCF(:,2:end); 
end 

if strcmpi(rateOption,'zeroCurve') % this is not de-bugged
   from = datestr(rateData.dates(1),'mm/dd/yyyy'); 
   to = datestr(datenum(endDate), 'mm/dd/yyyy'); 
   bbgData = history(c, {eqTicker}, {'PX_LAST'}, from, to, {calcFreq, 'calendar'}, 'USD'); 
   mktData = [bbgData, rateData]; 
else 
   rateOption = 'flatCurve'; 
   rateTicker = rateData; 
   from = datestr(datenum(startDate), 'mm/dd/yyyy'); 
   to = datestr(datenum(endDate), 'mm/dd/yyyy'); 
   bbgData = history(c, [{eqTicker},{rateTicker}],{'PX_LAST'}, from, to, {calcFreq, 'calendar'}, 'USD'); 
   mktData = [bbgData{1},bbgData{2}(:,2)]; 
end 

erpb = zeros(size(mktData(:,2))); 
erpb2 = erpb;
erpb3 = erpb;
poYld = erpb2;
erpbIndex = erpb2;
CF = forecast.values(1,2:end-1);
oMtrx = zeros(size(erpb,1),(2*size(CF,2)+4) ); 
if strcmpi(cfFreq,'annual') && strcmpi(rateOption,'flatCurve')
   for t = 1 : length(mktData)
      indx = find(mktData(t,1)>=forecast.dates,1,'first'); 
      if isempty(indx); indx=1; end
      temp = forecast.values(indx,1:end);
      erpbIndex(t,:) = indx;
      currentPrice = mktData(t, 2);
      poYld(t,1) = temp(1,1)/currentPrice;
      CF = temp(1,2:end-1);% NOTE: size(CF,2) should be = to K+1
      g = temp(1, end);
      r = repmat(mktData(t,3)/100, [1, size(CF,2)]);
      erpb3(t,1) = fundData.Net_Cash_Yield(indx,:) + g - r(1,1);
      x0 =  poYld(t,1) + g - r(1); 
      fun = @calcPrice; 
      options = optimset('Display', 'off'); 
      erpb2(t,1) = x0;
      erpb(t,1) = fsolve(fun, x0, options);
      oMtrx(t,:)=[mktData(t,1),currentPrice,g,erpb(t,1),r,CF]; % date,px(t),g,erpb,rates,CF
   end
   temp = erpb;
   clear erpb;
   erpb.dates = mktData(:,1);
   erpb.header = {'px','erpb'};
   erpb.value = [mktData(:,2),mktData(:,3),temp]; 
elseif strcmpi(cfFreq,'quarterly') && strcmpi(rateOption,'flatCurve')
   for t = 1 : length(mktData)
      indx = find(mktData(t,1)>=forecast.dates,1,'last'); 
      if isempty(indx); indx=1; end
      erpbIndex(t,:) = indx;
      temp = forecast.values(indx,1:end);
      CF2 = temp(1,2)*(1+temp(1,end)).^(1:K); %#ok<NASGU>
      currentPrice = mktData(t,2);
      poYld(t,1) = temp(1,1)/currentPrice; 
      CF = temp(1,2:end-1); % NOTE: size(CF,2) should be = to K+1
      g = temp(1,end);
      r = repmat(mktData(t,3)/400,[1, size(CF,2)]);
      erpb3(t,1) = fundData.Net_Cash_Yield(indx,:) + g - r(1,1);
      x0 =  poYld(t,1) + g - r(1);
      fun = @calcPrice; 
      options = optimset('Display', 'off'); 
      erpb2(t,1) = x0;
      erpb(t, 1) = fsolve(fun, x0, options);
      oMtrx(t,:)=[mktData(t,1),currentPrice,g,erpb(t,1),r,CF]; % date,px(t),g,erpb,rates,CF
   end 
   
   temp = [4*erpb, 4*erpb3]; % annualize quarterly rates
%   temp2 = 4*erpb2; % annualize quarterly rates
   clear erpb erpb2; %
   erpb.dates = mktData(:,1);
   erpb.header = {'px','intRate','erpb','erpbAnal'};
   erpb.value = [mktData(:,2),mktData(:,3),temp]; 
   xx1 = []; xx2 = xx1;
   for t=1:length(r) 
      xx1 = [xx1,{['r',num2str(t)]}]; %#ok<AGROW>
      xx2 = [xx2,{['CF',num2str(t)]}]; %#ok<AGROW>
   end  
   oTable = array2table(oMtrx,'Variable',[{'date','px','g','erpb'},xx1,xx2]); 
%    erpb2.dates = mktData(:,1);
%    erpb2.header = {'px','erpb'};
%    erpb2.value = [mktData(:,2),temp2]; 

% YOU ARE HERE:
elseif strcmpi(cfFreq,'annual') && strcmpi(rateOption,'zeroCurve')
    
else % strcmpi(cfFreq,'quarterly') && strcmpi(rateOption,'zeroCurve')
    
end 

function price = calcPrice(x)
    DF = ((1 + x + r).^-(1:length(r))); 
    price = -1 * currentPrice + sum(CF(1,1:K).*DF(1,1:K)) + DF(1,K)*CF(end)/(r(end)+x-g);
end

end