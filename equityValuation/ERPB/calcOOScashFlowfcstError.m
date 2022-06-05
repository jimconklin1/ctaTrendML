function [mse, errorTable] = calcOOScashFlowfcstError(fcstTable,netCashFlow,params,K,t0)
% Inputs:
% fcstTable   = forecasted net cashflows, where Date is the point-in-time of
%               the forecst
% netCashFlow = historical (realized) net cashflows
% freq        = 'quarterly', 'annual'
% K           = number of periods ahead fcstTable projects + 1
% t0          = first period forecasted cashflows get differenced with
%               actuals (default is 1)
% opt         = 'percent','yield' -- units of errors; percent is cashflow
%               diff/actual cashflow, yield is cashflow diff / index price

% Outputs: 
% mse         = mean squared error of forecasts 
% errorTable  = individual forecast errors by period and forecast tenor

freq = params.payoutDataFrequency;
if nargin < 4
   if strcmpi(freq,'quarterly')
      K = 21;
   else
      K = 6; % vector of k-yrs ahead fcst
   end
end

if nargin < 5
   t0 = 1; % vector of k-yrs ahead fcst
end 
if strcmpi(freq,'quarterly')
   t0 = max([t0,find(fcstTable.Q0~=0,1,'first')]);
   t0 = max([t0,find(~isnan(fcstTable.Q0),1,'first')]);
else
   t0 = max([t0,find(fcstTable.Y0~=0,1,'first')]);
   t0 = max([t0,find(~isnan(fcstTable.Y0),1,'first')]);
end

if nargin < 6
   opt= 'percent';
end

if strcmp(params.dataOption,'bbgHardCopy')
  cf = netCashFlow.netPayout;
else
  cf = netCashFlow.Net_Cash_to_Equity;
end
px = netCashFlow.Market_Value; 
dates = netCashFlow.Date; 

T = size(fcstTable,1);
fcstMtx = table2array(fcstTable);
cfError = zeros(T,K);
percentError = zeros(T,K); 
yieldError = zeros(T,K);
for t = t0:T
  KK = min([T,t+K])-t; 
  temp = [fcstMtx(t,(2+(1:KK))); cf((t+(1:KK)),:)'];
  cfError(t,1:KK) = (temp(1,:) - temp(2,:)); 
  percentError(t,1:KK) = cfError(t,1:KK)./temp(2,:);
  yieldError(t,1:KK) = cfError(t,1:KK)/px(t); 
end 

if strcmpi(freq,'quarterly')
   switch opt
      case 'percent'
         errorTable = array2table([dates(t0:end,:), percentError(t0:end,:)],'VariableNames',{'Date','Q1','Q2','Q3','Q4','Q5','Q6', ...
                                  'Q7','Q8','Q9','Q10','Q11','Q12','Q13','Q14','Q15','Q16','Q17','Q18','Q19','Q20','Q21'});
         mse = mean(percentError(t0:end,:).^2); 
      case 'yield'
         errorTable = array2table([dates(t0:end,:), yieldError(t0:end,:)],'VariableNames',{'Date','Q1','Q2','Q3','Q4','Q5','Q6', ...
                                  'Q7','Q8','Q9','Q10','Q11','Q12','Q13','Q14','Q15','Q16','Q17','Q18','Q19','Q20','Q21'});
         mse = mean(yieldError(t0:end,:).^2); 
   end
   mse = array2table(mse,'VariableNames',{'Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10',...
                     'Q11','Q12','Q13','Q14','Q15','Q16','Q17','Q18','Q19','Q20','Q21'}); 
else
   switch opt
      case 'percent'
         errorTable = array2table([dates(t0:end,:), percentError(t0:end,:)],'VariableNames',{'Year','Y1','Y2','Y3','Y4','Y5','Y6'});
         mse = mean(percentError(t0:end,:).^2); 
      case 'yield'
         errorTable = array2table([dates(t0:end,:), yieldError(t0:end,:)],'VariableNames',{'Year','Y1','Y2','Y3','Y4','Y5','Y6'});
         mse = mean(yieldError(t0:end,:).^2); 
   end
   mse = array2table(mse,'VariableNames',{'Y1','Y2','Y3','Y4','Y5','Y6'}); 
end

end % fn