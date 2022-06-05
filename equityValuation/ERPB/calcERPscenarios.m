function [px, erp, pxKper] = calcERPscenarios(px0,CF0,dataFrame,erp0,perType)
% inputs:
%  perType: 'annual' or 'quarterly'

% dataFrame represents forward projections, from period 0, of the following
%   variables (each variable is a row):
% kk: forward period index, i.e., 0.25, 0.5, ... 1.75 ... etc. if quarterly data
% r:  forward-forward real risk free rates, annual units (i.e., from period k-1 to period k)
% pi: forward-forward expected inflation rate (i.e., from period k-1 to period k)
% g:  forward-forward real growth rate (i.e., from period k-1 to period k)

K = size(dataFrame,2); 
kk = dataFrame(1,:); 
r = dataFrame(2,:);
pi = dataFrame(3,:);
g = dataFrame(4,:);

if nargin < 4 || isempty(erp0) % case where we determine ERP from price
   erpb0 = mean(g) - mean(r) + 0.01; % discount factor must be > growth factor in steady state
   % note; in the logic below r represents the zero coupon rate at each
   % maturity -- using the same rate at each maturity
   temp = ones(1,K)+g+pi;
   CF = CF0*temp.^kk; 
   currentPrice = px0;
   fun = @calcPrice; 
   x0 = erpb0; 
   options = optimset('Display', 'off'); 
   xx = fsolve(fun, x0, options); 
   erp = xx; 
   px = px0;
   df = ((1 + erp0 + r(1,K-1))^-(K-1));
   pxKper = df*CF(K)/(r(K)+erp-g(K));
elseif ~isempty(erp0) 
   DF = ((1 + erp0 + r).^-(1:K)); 
   temp = ones(1,K)+g+pi;
   CF = CF0*temp.^kk; 
   erp = erp0;
   px = sum(CF(1,1:K-1).*DF(1,1:K-1)) + DF(1,K-1)*CF(K)/(r(K)+erp-g(K));
   pxKper = DF(1,K-1)*CF(K)/(r(K)+erp-g(K));
end 
function price = calcPrice(x)
    DF = ((1 + x + r).^-(1:length(r))); 
    price = -1 * currentPrice + sum(CF(1,1:K-1).*DF(1,1:K-1)) + DF(1,K-1)*CF(K)/(r(K)+x-g(K));
end

end