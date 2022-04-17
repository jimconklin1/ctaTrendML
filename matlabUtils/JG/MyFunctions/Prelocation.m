function [ptfret, volptf, s, ExecP, nb, wgt, tottrancost, grossreturn, ...
   tcforec, GeoEC, HoldShort, HoldLong, Hlong, Lshort ] = Prelocation(c)

% .. Portfolio volatility ..
ptfret=zeros(size(c,1),1);  volptf=zeros(size(c,1),1);
% .. Signals ..
s=zeros(size(c));
% .. Execution Prices ..
ExecP=zeros(size(c));  
% .. Number of Shares ..
nb=zeros(size(c));
% .. Weightts ..
wgt=zeros(size(c));    
% .. Profit ..
%profit=zeros(size(c));          sumprofit=zeros(size(c));
%grossprofit=zeros(size(c));     sumgrossprofit=zeros(size(c));
tottrancost=zeros(size(c));     
% .. Equity Curve ..
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c));     GeoEC=zeros(size(c)); 
% -- Holding Period --
HoldShort=zeros(size(c));   HoldLong=zeros(size(c));  
% -- Maximum & Minimum reached over the trade --
Hlong=zeros(size(c));       Lshort=zeros(size(c));  