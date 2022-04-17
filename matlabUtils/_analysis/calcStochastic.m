function [k, d] = calcStochastic(dataStruct,kLB, dLB)
% NOTE: NOT TESTED!
% Investopedia:
% Stochastics is measured with the %K line and the %D line, and it is the %D line that we follow closely, for it will indicate any major signals in the chart. Mathematically, the %K line looks like this:
% 
% %K = 100[(C – L5close)/(H5 – L5)]
% C = the most recent closing price
% L5 = the low of the five previous trading sessions
% H5 = the highest price traded during the same 5 day period.
% 
% The formula for the more important %D line looks like this:
% 
% %D = 100 X (H3/L3)


Read more: Stochastics: An Accurate Buy And Sell Indicator http://www.investopedia.com/articles/technical/073001.asp#ixzz4er9tcoz8 
Follow us: Investopedia on Facebook

if nargin < 3 || isempty(dLB)
   dLB = 3;
end
if nargin < 2 || isempty(kLB)
   kLB = 5;
end

k = zeros(size(dataStruct.close));
d = zeros(size(dataStruct.close));
Lk = zeros(size(dataStruct.close));
Hk = zeros(size(dataStruct.close));
Ld = zeros(size(dataStruct.close));
Hd = zeros(size(dataStruct.close));

for t = max(kLB,dLB)+1:length(Lk)
    Lk(t,:) = min(dataStruct.low(t-kLB+1:t,:)); 
    Hk(t,:) = max(dataStruct.high(t-kLB+1:t,:)); 
    Ld(t,:) = min(dataStruct.low(t-dLB+1:t,:)); 
    Hd(t,:) = max(dataStruct.high(t-dLB+1:t,:)); 
    k(t,:) = 100*(dataStruct.close(t,:) - Lk(t,:))./(Hk(t,:) - Lk(t,:));
    d(t,:) = 100*Hd(t,:)./Ld(t,:);
end % for t
end % fn