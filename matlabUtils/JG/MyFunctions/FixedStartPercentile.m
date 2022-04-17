function px = FixedStartPercentile(x, MinPctPeriod)
%
%__________________________________________________________________________
%
% RollingPercentile
% INPUT
% LookbackPeriod = period for moving avergae;
% PctPeriod = lookback period for Percentage Rank
%__________________________________________________________________________
%

% -- Dimensions & Parameters & Prelocate Matrices --
[nsteps,ncols] = size(x); 
px = zeros(size(x));

% -- --
for j=1:ncols
    start_date=zeros(1,1);
    % Step 1: find the first cell to start the code  
    for i=1:nsteps      
        if ~isnan(x(i,j))
            start_date(1,1)=i;  
            break
        end
    end
    %
    y(1:start_date(1,1) + MinPctPeriod,j) = zeros(start_date(1,1) + MinPctPeriod,1);
    for i = start_date(1,1) + MinPctPeriod : nsteps
        y = x(start_date(1,1):i,j); % populate
        py = PercentileRank(y,'excel'); % PercentileRank
        [rpy,~] = size(py); % Dimension
        px(i,j) = py(rpy,1); % Assign
    end
end

