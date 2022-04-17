function[nbc] = NbCross(x,lookback)

%The function frsi computes the rsi
% nbd is the period over which the rsi is computed (usually, 14 days)
% smooth_per is the average of the rsi over a given period (5 for instance)

[nsteps,ncols] = size(x); 
tot = zeros(size(x)); 
nbc = zeros(size(x)); 
mac=expmav(x,lookback);

for j=1:ncols
    % Step 1: find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j))
            start_date(1,1)=i;
        break               
        end                                 
    end
    for i=start_date(1,1)+lookback:nsteps
        if sign(x(i-1,j)-mac(i-1,j)) ~= sign(x(i,j)-mac(i,j))
            tot(i,j)=1;
        end
    end
    for i=start_date(1,1)+lookback:nsteps
        nbc(i,j)=100*sum(tot(i-lookback+1:i,j))/lookback;
    end    
end
clear tot


