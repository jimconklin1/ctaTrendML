function [mdates,mrets] = makeMonthlyRets(ddates,drets)
% converts daily returns to weekly returns
% Inputs: 
%   drets = daily return matrix
% Outputs: 
%   mrets = monthly returns 

[~,N] = size(drets); % handy variables

% deal w/ date stuff:
indxME = find(month(ddates(1:end-1,:))~=month(ddates(2:end,:)));
mdates = ddates(indxME); %#ok
mT = size(mdates,1); 

% handle data: 
mrets = zeros(mT,N); 
for n = 1:N
   t0 = calcFirstActive(drets(:,n),0); 
   cumDrets = calcCum(drets(t0:end,n)); 
   cumIndxME = find(month(ddates(t0:end-1,:))~=month(ddates(t0+1:end,:)));
   temp = cumDrets(cumIndxME,1);  %#ok
   tempMRets = temp(2:end,1) - temp(1:end-1,1); 
   t1 = size(tempMRets,1)-1; 
   mrets(end-t1:end,n) = tempMRets; 
end % for n





