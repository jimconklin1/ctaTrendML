%
%__________________________________________________________________________
%
% Function to Compute P&L at the stock / Future level
% Step 1 adjust the transaction cost
% Step 2 compute the P&L
%__________________________________________________________________________
%

function p = ChoseExecutionPrice(o,h,l,c,vwap, method, OpenWgt)
%
% -- Dimensions & Prelocate matrices --
[nsteps,ncols]=size(c);
p=zeros(size(c));

%
% -- Chose execution price
switch method
    case {'open'}
        p(1:nsteps-1,:) = o(2:nsteps,:);
        p(nsteps,:) = p(nsteps-1,:);
    case{'atp'}
        p(1:nsteps-1,:) = (o(2:nsteps,:)+h(2:nsteps,:)+l(2:nsteps,:)+c(2:nsteps,:))/4; 
        p(nsteps,:) = p(nsteps-1,:);
    case {'atp_open'}
        open_weight = OpenWgt;
        p(1:nsteps-1,:) = open_weight*o(2:nsteps,:) + (1-open_weight)/3*(h(2:nsteps,:) + l(2:nsteps,:) + c(2:nsteps,:));
        p(nsteps,:) = p(nsteps-1,:);
    case {'vwap'}
        p(1:nsteps-1,:)=vwap(2:nsteps,:); 
        p(nsteps,:)=p(nsteps-1,:);      
    case {'vwap_open'}
        open_weight = OpenWgt;
        p(1:nsteps-1,:) = open_weight*o(2:nsteps,:)+(1-open_weight)*vwap(2:nsteps,:);
        p(nsteps,:) = p(nsteps-1,:); 
end
