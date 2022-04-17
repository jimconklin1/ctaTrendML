function[dist, pdist] = PctOscillator(x,LookbackPeriod, PctPeriod)
%
%__________________________________________________________________________
%
% Oscillator based on percentage distance compared to moving average
% INPUT
% LookbackPeriod = period for moving avergae;
% PctPeriod = lookback period for Percentage Rank
%__________________________________________________________________________
%

% -- Dimensions & Parameters & Prelocate Matrices --
[nsteps,ncols] = size(x); 
pdist = zeros(size(x));
% Define the period over which the RSI is computed

% -- --
ma = expmav(x,LookbackPeriod);

% -- --
dist = (x - ma) ./ ma;
dist(isinf(dist)) = 0;
dist(isnan(dist)) = 0;
dist(1:LookbackPeriod+1, :) = zeros(LookbackPeriod+1, ncols);
clear ma

% -- Distance to moving average --
y = zeros(PctPeriod, 1);

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
    dist(1:start_date(1,1)+1,j) = zeros(start_date(1,1),1);
    for i = start_date(1,1) + LookbackPeriod + PctPeriod : nsteps
        y = dist(i - PctPeriod + 1:i,j); % populate
        py = PercentileRank(y,'excel'); % PercentileRank
        [rpy,cpy] = size(py); % Dimension
        pdist(i,j) = py(rpy,1); % Assign
    end
end

