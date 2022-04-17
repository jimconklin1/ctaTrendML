function px = RollingPercentile(x, PctPeriod)
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

% -- Distance to moving average --
y = zeros(PctPeriod, 1);

% -- --
for j=1:ncols
    startDate=zeros(1,1);
    % Step 1: find the first cell to start the code  
    for i=1:nsteps      
        if ~isnan(x(i,j))
            startDate(1,1)=i;  
            break
        end
    end
    %
    for i = startDate(1,1) + PctPeriod : nsteps
        y = x(i - PctPeriod + 1:i,j); % populate
        py = PercentileRank(y,'excel'); % PercentileRank
        [rpy,~] = size(py); % Dimension
        px(i,j) = py(rpy,1); % Assign
    end
end

