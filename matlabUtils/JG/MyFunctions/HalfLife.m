function hl = HalfLife(x, Lag, Lookback, method)
%
%__________________________________________________________________________
%
% This Function estimates the Half Life of the stochastic process
% INPUT:
% - Matrix of Close 
% - Lag for x (1 day, 1 week, 1 month...)
% - Lookback: Lookback period for N (Exp de ATR)
% - method: 'fixed', if estimaton since the start of the time series
%           'rolling' if o a rolling window
% OUTPUT:
% half life
%x=c(:,1);Lag=1; Lookback=200; method='rolling';
%__________________________________________________________________________
%
% -- Prelocate the matrix --
hl = zeros(size(x));
[nsteps,ncols]=size(x);


dx = Delta(x,'dif',Lag); % difference

for j=1:ncols
    
    % Find the first cell to start the code
    for i=1:nsteps
        if ~isnan(x(i,j)), start_date=i;
        break
        end
    end
    
    switch method
    
        case 'rolling'
            % Constant
            ct_x = ones(Lookback,1); 
            % Rolling regression
            for i = start_date + 1 + Lag +  Lookback : nsteps
                % Compute Rolling regression
                dx_v = dx(i- Lookback + 1:i,j); 
                x_v  = [x(i- Lookback + 1 - Lag :i - Lag,j), ct_x]; 
                b = regress(dx_v, x_v);  
                % Half Life
                if size(b,1)==2 && b(1) ~= 0,
                    hl(i,j) = -log(2) / b(1);
                else
                    hl(i,j) = hl(i-1,j);
                end
            end
            
        case 'fixed'
            time_inc = 1;    % Minimum of 10 points to start with
            for i = start_date + Lag : nsteps
                % Compute Rolling regression
                time_inc = time_inc + 1;  % Update time increment
                ct_x = ones(time_inc-1,1);  % Constant
                dx_v = dx(start_date : i , j); 
                x_v  = [x(start_date - Lag : i - Lag , j), ct_x]; 
                b = regress(dx_v, x_v); 
                % Half Life
                if size(b,1)==2 && b(1) ~= 0,
                    hl(i,j) = -log(2) / b(1);
                else
                    hl(i,j) = hl(i-1,j);
                end
            end          
            
    end
end

