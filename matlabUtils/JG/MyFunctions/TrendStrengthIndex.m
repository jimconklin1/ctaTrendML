function [tsi,tsima] = TrendStrengthIndex(c,h,l, method, parameters)
%
%--------------------------------------------------------------------------
%
% TSI is Trend Strength Index

% TSI is an indicator designed to identify true trend strength.
% A high TSI value indicates that short-term trend continuation 
% (follow through) is more likely than short-term trend reversal
% (mean reversion). For e.g., in the case of the TSI computed with the ATR
% method, NASDAQ100 stocks with a value of greater than 1.65 indicate
% a healthy trend environment. 
% It also proves to be an excellent oscillator identifying overbought
% (extreme positive values, 4 to 6) and oversold (extreme negative values
% -4 to -6)% territories.
%
%
% Two methods are used:
% method 1: computation is based on the Average True Range (atr)
% method 2: defined in "Momentum, Direction and Divergence", William Blau,
%           Willey, p. 5, this method is based on the 1-bar
%           momentum(for e.g., 1-day) and a double-exponential-smoothing
%           average device.
%           Different set-ups look interesting:
%           set-up 2.1.: tsi(25,13)= ema(ema(r1d,25),13);
%                        signal line: ema_tsi=expmav(tsi,7);
%                        [tsiwb, matsiwb] = TrendStrengthIndex(c,h,l,
%                        'mom', [25,13,7]);
%           set-up 2.2.: W. Blau also defines the Ergodic Indicator as:
%                        Ergodic(close,r) = TSI(Close, r, 5)
%                        SignalLine(close,r) = EMA(TSI(close, r, 5), 5)
%                        [tsiwb, matsiwb] = TrendStrengthIndex(c,h,l,'mom', [r,5,5]);
%                        This "ergodic" means that the only variable that
%                        varies is the first exponential average, "r"
%                        Interesting set-ups are r=20 or 32
%
% -- Input --
% methods: 'ATR' and 'momentum' (1-bar momentum)
% parameters for the 'ATR' method:
%     - parameters(1) is the period for the ATR and the momentum (difference)
%     - parameters(2) is the period for signal (exponential moving average)
% parameter for the 'Momentum' method:
%     - parameters(1) is the period for the 1st exponential moving average
%     - parameters(2) is the period for the 1st exponential moving average
%     - parameters(3) is the period for signal (exponential moving average)
% -- Output --
% tsi = the TSI
% tsima = the smoothed TSI (signal)
%--------------------------------------------------------------------------
%
switch method
    case{'atr', 'ATR', 'average true range'}
        % -- ATR & x-day difference in Close Price --
        atr = ATRFunction(c,h,l, parameters(1),3);
        dif = Delta(c,'dif', parameters(1));
        %atr_ma = expmav(atr, parameters(1,2));
        %dif_ma = expmav(dif, parameters(1,2));
        % -- Trend Strength Index --
        tsi = (dif) ./ atr;
        %tsima = (dif_ma) ./ atr_ma;
        tsima = expmav(tsi, parameters(2));
        % -- Clean --
        [nsteps,ncols]=size(c);
        for j=1:ncols
            % Find first non empty
            %start_date=zeros(1,1);
            %for i=1:nsteps
            %    if ~isnan(y(i,j))
            %        start_date(1,1)=i;
            %    break               
            %    end                                 
            %end    
            for i=1:nsteps
                if isnan(tsi(i,j)), tsi(i,j) = 0; end
                if isnan(tsima(i,j)), tsima(i,j) = 0; end
            end
        end
    case{'mom', 'momentum', 'absdif' , 'abs_dif', 'abs dif', 'abs'}
        dif = Delta(c,'dif',1);
        absdif = abs(dif);
        ema_dif = expmav(dif, parameters(1));
        ema_absdif = expmav(absdif, parameters(1));
        ema_dif2 = expmav(ema_dif, parameters(2));
        ema_absdif2 = expmav(ema_absdif, parameters(2));  
        tsi = 100 * ema_dif2  ./ ema_absdif2;
        tsima = expmav(tsi,parameters(3));
        % -- Clean --
        [nsteps,ncols]=size(c);
        for j=1:ncols
            if isnan(tsi(1,j)),
                tsi(1,j) = 0;
            end
            if isnan(tsima(1,j)),
                tsima(1,j) = 0;
            end            
        end
        for j=1:ncols
            % Find first non empty
            %start_date=zeros(1,1);
            %for i=1:nsteps
            %    if ~isnan(y(i,j))
            %        start_date(1,1)=i;
            %    break               
            %    end                                 
            %end    
            for i=2:nsteps
                if isnan(tsi(i,j)) || tsi(i,j) == Inf || tsi(i,j) == -Inf
                    tsi(i,j) = tsi(i-1,j); 
                end
                if isnan(tsima(i,j)) || tsima(i,j) == Inf || tsima(i,j) == -Inf
                    tsima(i,j) = tsima(i-1,j); 
                end
            end
        end
end           
     