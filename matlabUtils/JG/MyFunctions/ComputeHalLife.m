function halflife = ComputeHalLife(x, RollingWindow)
%
%__________________________________________________________________________
%
% Compute half life 
%__________________________________________________________________________

% -- Dimensin & Prleocate matrices --
[nsteps, ncols]=size(x);
halflife = zeros(size(x));

for j=1:ncols
    
    for i=RollingWindow+1:nsteps
        
        snap_x = x(i-RollingWindow+1:i,j);
        snap_x_lag = lag(snap_x, 1);  % lag is a function in the jplv7 (spatial-econometrics.com) package.
        delta_snap_x=snap_x-snap_x_lag;
        delta_snap_x(1)=[]; % Regression functions cannot handle the NaN in the first bar of the time series.
        snap_x_lag(1)=[];
        regress_results=ols(delta_snap_x, [snap_x_lag ones(size(snap_x_lag))]); % ols is a function in the jplv7 (spatial-econometrics.com) package.
        hl=-log(2)/regress_results.beta(1);
        halflife(i,j) = hl;
    end
    
end
