function bko = channelbreakout(h,l,c,Lookback, method)
%
%__________________________________________________________________________
%
% The function "channelbreakout" identifies the breakout (long & short)
% over a certain period
%
% -- INPUTS:
% - method: 'close' - computes the breakout based on close 
%           'high-low' - computes the breakout based on highs & lows 
% - Lookback is the period over which the moving average is computed
% -- OUTPUT:
% - triangular  moving average
%__________________________________________________________________________

% -- Prelocate Matrices & Identify Dimensions --
[nsteps,ncols] = size(c);
bko = zeros(size(c));

%
switch method
    case 'close'
        for j=1:ncols
            for i=Lookback+1:nsteps
                if c(i,j) >= max(c(nsteps-Lookback-1:nsteps))
                    bko(i,j) = 1;
                elseif c(i) <= min(c(nsteps-Lookback-1:nsteps))
                    bko(i,j) = -1;
                end 
            end
        end
    case 'high-low'  
        for j=1:ncols
            for i=Lookback+1:nsteps
                if c(i,j) >= max(c(nsteps-Lookback-1:nsteps))
                    bko(i,j) = 1;
                elseif c(i) <= min(c(nsteps-Lookback-1:nsteps))
                    bko(i,j) = -1;
                end 
            end
        end
end

