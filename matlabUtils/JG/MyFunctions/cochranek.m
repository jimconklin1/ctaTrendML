function y = cochranek(x,lag, lookback)
%
%__________________________________________________________________________
%
% This code compute the meaningful statistical trend on a rolling basis
% Input: -  x        = Asset Price
%        -  Lokkback = Lookback period
% Output: - slope      = slope
%         - intercept   statistical signification (look for abs(smt)>2.5
%__________________________________________________________________________
%
%
% -- Prelocate Matrix --
[nsteps,ncols]=size(x);
x1 = zeros(size(x));
xlag = zeros(size(x));
y1 = zeros(size(x));
ylag = zeros(size(x));
y = zeros(size(x));

x1(2:nsteps,:)=x(1:nsteps-1,:);
xlag(lag+1:nsteps,:)=x(1:nsteps-lag,:);
dx1=x-x1;
dxlag=x-xlag;

%
% -- Run Loop --
for j=1:ncols
    % .. Identify Start ..
    start_date(1,1)=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j)) && x(i,j)~=0
            start_date(1,1)=i;
            break
        end
    end 
    % .. Run Model ..
    % Step 2: Compute standard deviation
    if nsteps>lookback+lag
        for k=start_date(1,1)+lookback+lag:nsteps
            ylag(k,j) = std(dxlag(k-lookback+1:k,j));
        end
    end
    if nsteps>lookback
        for k=start_date(1,1)+lookback+lag:nsteps
            y1(k,j) = std(dx1(k-lookback+1:k,j));
        end
    end  
    ylag(1,j) = 0.5/100;
    y1(1,j) = 0.5/100;
    for k=2:nsteps
        if  isnan(ylag(k,j)) || ylag(k,j)==0 || ylag(k,j)==Inf
            ylag(k,j) = ylag(k-1,j);
        end
    end
    for k=2:nsteps
        if  isnan(y1(k,j)) || y1(k,j)==0 || y1(k,j)==Inf
            y1(k,j) = y1(k-1,j);
        end
    end    
end
y = 1/lag * (ylag ./ y1);
clear ylag y1
