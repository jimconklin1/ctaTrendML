function[K,D,SD] = StochasticFunction(c,h,l,method,LookbackPeriod,SmoothK,SmoothD)
%__________________________________________________________________________
%
% The function computes the Stochastic Oscialltor
% Developed by George C. Lane in the late 1950s, the Stochastic Oscillator 
% is a momentum indicator that shows the location of the close relative to 
% the high-low range over a set number of periods.
% According to Lane, the Stochastic Oscillator "doesn't follow price, 
% it doesn't follow volume or anything like that.
% It follows the speed or the momentum of price. As a rule, the momentum 
% changes direction before price." 
% As such, bullish and bearish divergences in the Stochastic Oscillator can
% be used to foreshadow reversals. 
% Lane also used this oscillator to identify bull and bear set-ups to
% anticipate a future reversal. 
% Because the Stochastic Oscillator is range bound, is also useful for 
% identifying overbought and oversold levels.
%
% MODEL--------------------------------------------------------------------
% K = (Current Close - Lowest Low) / (Highest High - Lowest Low) * 100
% D = 3-day Exp.MA or Simple.MA of %K
% Lowest Low = lowest low for the look-back period
% Highest High = highest high for the look-back period
% K is multiplied by 100 to move the decimal point two places
%
% note: Wikepedia uses exponential moving average for %D and %SD while
% StockCharts.com and Kauffman uses simple (arithmetic) moving average.

%
% Fast Stochastic Oscillator: 
%   %K = Fast %K = %K basic calculation
%   %D = Fast %D = 3-period SMA of Fast %K
%
% Slow Stochastic Oscillator: 
%   Slow %K = Fast %K smoothed with 3-period SMA
%   Slow %D = 3-period SMA of Slow %K
%
% INPUT--------------------------------------------------------------------
% LookbackPeriod = Look-back period for lowest low and highest high
% Close, High, Low (in this order, very important)
% SmoothK = Period to smooth K which gives %D
% SmoothD = Period to smooth K which gives %SD
% method: - {'expma', 'ema'} : exponential moving average
%         - {'arithma', 'ama', 'simple ma', 'simplema'} ; arithmetic moving
%         average. This method is the one Lane followed.
%
% OUTPUT-------------------------------------------------------------------
% The model computes
% %K = Fast K
% %D = Fast D
% %SD= Slow D
%
% DIFFERENT SET UP---------------------------------------------------------
% Bloomberg default: 20,5,5,3
% Wikepedia: typical values for look-back period are 5, 9, or 14 periods.
%             Smoothing the indicator over 3 periods is standard
% typically: [lsk,lsd,lssd] = StochasticFunction(c,h,l,'ama',20,5,5);
%__________________________________________________________________________

% DIMENSION & PRELOCATE MATRIX---------------------------------------------
[nsteps,ncols] = size(c); 
R = zeros(size(c)); K = zeros(size(c)); 
%
for j=1:ncols
    % -- Find the first cell to start the code --
    for i=1:nsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
            break
        end
    end 
    for i=LookbackPeriod+start_date-1:nsteps
        % -- Define the range --
        MaxH = max(h(i-LookbackPeriod+1:i,j));
        MinL = min(l(i-LookbackPeriod+1:i,j));
        R(i,j) = MaxH - MinL;
        % -- Compute K --
        if ~isnan(R(i,j)) && R(i,j)>0
            K(i,j) = 100 * (c(i,j) - MinL) / R(i,j);
        end
    end
    %
end
%
% -- Cap Stochastic K --
K(find(K<0)) = 0; K(find(K>100)) = 100;    
%
% -- Compute %D & %SD
switch method
    case {'expma', 'ema'}
        D = expmav(K,SmoothK);
        SD = expmav(D,SmoothD);   
    case {'arithma', 'ama', 'simple ma', 'simplema'}
        D = arithmav(K,SmoothK);
        SD = arithmav(D,SmoothD);
end

        
