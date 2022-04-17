function[convl, basel, lagl, ssa, ssb, sign1, sign2, sign3, sign] = ichomuku(c,h,l,conv_per, base_per, lag_per, lead_per)
%
%__________________________________________________________________________
%
% This Function computes the Ichimoku system
%
% most used set up
%[convl, basel, lagl, ssa, ssb, sign1, sign2, sign3, sign] = ichomuku(c,h,l, 9, 26, 26, 26)
%
% -- INPUT:
% - Matrix of Close, High , Low
% - Conversion period, base period, lag period & lead period
%   default: conv_per (Tenkan Sen) = 9 
%            base_per (Kijun Sen) = 26;
%            lag_per (Chikou Span) = 26; 
%            lead_per = 26
%
% -- OUTPUT:
%
% - Conversion Line = Tenkan Sen
% Short term trend line. Known as the turning line and is a signal of
% a region of minor support or resistance.
%
% - Base Line = Kijun Sen
% Confirmation line. This component serves as a signal fo rsupport and
% resistance levels. Can be used as a trailong stop. Serves also as an
% indicator of trend.
%
% - Lag Lines = Chikou (or Chinkou) Span 
% Is a lgging indicator, i.e. current price shifted back 26 periods . Used
% as confirmation of signals and can also serve as a support or resistance
% level. Can be used in confirming the direction and strength of trends.
%
% - Senkou Span A (Lead1 line in Bloomberg)
% BOundary of the cloud. If the stock is trading above the line, th eline
% will serve as major support level. If trades below, it will serve as
% major resistance. Senkou Span A = (Tenkan Sen+Kijun Sen)/2. Results are
% plotted 26 periods ahead, meaning the today's Senkou Span A was actually
% plotted 26 days ago.
%
% - Senkou Span B (Lead2 line in Bloomberg)
% This line form the other boundary of the cloud. Serves as a second level
% of support and resistance and is calculated by taking the mid-point
% between the highest high and the lowest low over the past 52 days. Like
% the Senkou Span A, i tis also plotted 26 periods ahead. Line is similar
% to a 50% Fibonacci retracement.
%
% - Implicit output is "Kumo"
% Shaded area, located between the Senkou Span A and senkou Span B lines,
% used to form the cloud itself.
%
% - Signals form Ichomuku system
%
% The Cloud: Finding the Trend
% The trend is upward when price is above the Cloud.
% The trend is downward when price is below the Cloud.
% The trend is flat (undetermined) when price is in the Cloud.
 
% The Cloud is green when Senkou Span A is above Span B. A predominantly 
% green cloud indicates a strong up-trend (or weak down-trend), 
% while a predominantly red cloud indicates a strong down-trend 
% (or weak up-trend).
 
% -- Trading in an Up-trend
% Signals above the Cloud where the latest Cloud color (ahead) is green are 
% stronger than where the color is red.
% Go long when Tenkan-Sen (blue) crosses above Kijun-Sen (red).
% Go long when Price crosses above the Kijun-Sen (red) line.
% Exit when Price crosses below Kijun-Sen (red).
% Exit when Tenkan-Sen (blue) crosses below Kijun-Sen (red).
 
% -- Trading in a Down-trend
% stronger than where the color is green.
% Go short when Tenkan-Sen (blue) crosses below Kijun-Sen (red).
% Go short when Price crosses below the Kijun-Sen (red) line.
% Exit when Price crosses above Kijun-Sen (red).
% Exit when Tenkan-Sen (blue) crosses above Kijun-Sen (red).
 
% Kumo cloud: cloud above/below current price
% Future Kumo Cloud: Cloud 26 bars into the future
 
%__________________________________________________________________________
%
% -- Prelocate the matrix --
[nsteps,ncols]=size(c);
convl = zeros(size(c));
basel = zeros(size(c));
lagl = zeros(size(c));
ssb_cur = zeros(size(c)); ssb = zeros(size(c));
% signals
sign1 = zeros(size(c)); sign2 = zeros(size(c)); sign3 = zeros(size(c));
 
lookback_tenkansen = conv_per;
lookback_kijunsen = base_per;
lag_chikou  = lag_per;
period_SenkouSpanA = lead_per;
lookback_SenkouSpanB = 2 * lead_per;
period_SenkouSpanB = period_SenkouSpanA;
 
 
% -- Find Max Period to start the also --
perdiod_matrix = [lookback_tenkansen, lookback_kijunsen, lag_chikou,period_SenkouSpanA, lookback_SenkouSpanB];
max_period = max(perdiod_matrix );
 
for j=1:ncols
    
    % -- Find the first cell to start the code --
    for i=1:nsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
        break
        end
    end
    
    % -- Conversion Line - Tenkan Sen --
    for i=start_date+max_period:nsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i-1,j)) && ...
            h(i,j)>0 && l(i,j)>0 && c(i-1,j)>0
            convl(i,j) = ( max(h(i-lookback_tenkansen+1:i,j)) +  min(l(i-lookback_tenkansen+1:i,j)) ) / 2;
        end
    end
   % note: Bullish if Price > Tenkan Sen
   %       Bearish if Price < Tenkan Sen    
    
    % -- Base Line - Kijun Sen --
    for i=start_date+max_period:nsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i-1,j)) && ...
            h(i,j)>0 && l(i,j)>0 && c(i-1,j)>0
            basel(i,j) = ( max(h(i-lookback_kijunsen+1:i,j)) +  min(l(i-lookback_kijunsen+1:i,j)) ) / 2;
        end
    end   
    % note: Bullish if Price > Kijun Sen
    %       Bearish if Price < Kinjun Sen
    
    % -- Build Senkou Span B (For Kumo Cloud)  --
    for i=start_date+max_period:nsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i,j)) && ...
            h(i,j)>0 && l(i,j)>0 && c(i-1,j)>0
            ssb_cur(i,j) = ( max(h(i-lookback_SenkouSpanB+1:i,j)) +  min(l(i-lookback_SenkouSpanB+1:i,j)) ) / 2;
        end
    end      
    
end
 
% -- Lag Line - Chikou Span --
% Lag line is the Close price shifted left by 'lag_chikou'
% Bullish: if the Chikou Span is above price from 26 periods ago
% Bearish: if the Chikou Span is below price from 26 periods ago
lagl(lag_chikou + 1 :nsteps,:) = c(1:nsteps - lag_chikou ,:);
 
% -- Build Senkou Span A --
% note:  average of Conversion & Base lines, then shift right by period4
ssa_cur = (convl + lagl) / 2;
ssa(period_SenkouSpanA + 1 : nsteps, : ) = ssa_cur(1 : nsteps - period_SenkouSpanA,:);
 
% -- Build Senkou Span B --
ssb(period_SenkouSpanB + 1 : nsteps, : ) = ssb_cur(1 : nsteps - period_SenkouSpanB,:);
 
% -- Extract signals --
for j=1:ncols
    % -- Find the first cell to start the code --
    for i=start_date:nsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
        break
        end
    end
    %
    % -- Signal Conversion Line vs. Base Line --
    for i=start_date+max_period:nsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i,j)) 
            if convl(i-1,j) < basel(i-1,j) && convl(i,j) > basel(i,j)
                sign1(i,j) = 1;
            elseif convl(i-1,j) > basel(i-1,j) && convl(i,j) < basel(i,j)
                sign1(i,j) = -1;
            end
        end
    end    
    % -- Signal Lag Line vs. Close --
    for i=start_date+max_period:nsteps
        if lagl(i-1,j) < c(i-1,j) && lagl(i,j) > c(i,j)
            sign2(i,j) = 1;
        elseif lagl(i-1,j) > c(i-1,j) && lagl(i,j) < c(i,j)
            sign2(i,j) = -1;
        end
    end     
    % -- Signal Senkou Span A vs. Senkou Span B --
    for i=start_date+max_period:nsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i,j)) 
            if ssa(i,j) > ssb(i,j)
                sign3(i,j) = 1;
            else
                sign3(i,j) = -1;
            end
        end
    end       
    
end
% -- Sum of Signals --
sign = sign1+sign2+sign3;
