function [dater, or, hr, lr, cr, up, down, sr] = SmartRenko(datep, o, h, l, c, atr, boxsize, method)
%
%__________________________________________________________________________
%
% My solution for computing renko as the Matlab Renko fucntion does not
% give the output but just produces the chart
%
%__________________________________________________________________________
%
% -- Dimension, Initialisation & Prelocation --
nsteps = length(c); 
up(1) = c(1);   down(1) = c(1); dater(1) = datep(1);
or(1)=o(1);lr(1)=o(1);cr(1)=c(1);hr(1)=c(1);
sr = zeros(nsteps,1);

% -- Renko Algorithm --
switch method
    case 'atr'
        for i=2: nsteps
            atrboxsize=atr(i)/5;
            if c(i) > c(i-1) + atrboxsize
                up = [up ; up(length(up)) + atrboxsize];
                down = up;%[up ; up(length(up)) - atrboxsize];
                dater = [dater ; datep(i)];  
                sr(i) = 1;
            elseif c(i) < c(i-1) - atrboxsize
                down = [down ; down(length(down)) - atrboxsize];
                up = down;%[down ; down(length(down)) - atrboxsize];
                dater = [dater ; datep(i)];
                sr(i) = -1;
            else
                sr(i) = sr(i-1);
            end
        end
    case 'fixed'
        for i=2: nsteps
            if c(i) > c(i-1) + boxsize
                up = [up ; up(length(up)) + boxsize];
                down = up;%[up ; up(length(up)) - step];
                dater = [dater ; datep(i)];  
                sr(i) = 1;
            elseif c(i) < c(i-1) - boxsize
                down = [down ; down(length(down)) - boxsize];
                up = down;%[down ; down(length(down)) - step];
                dater = [dater ; datep(i)];
                sr(i) = -1;
            else
                sr(i) = sr(i-1);
            end
        end        
end
% -- Build Renko Chart --
for i=2:length(up)
    if up(i)>up(i-1)
        or=[or;up(i-1)];
        hr=[hr;up(i)];
        lr=[lr;up(i-1)];
        cr=[cr;up(i)];
    elseif up(i)<up(i-1)
        or=[or;down(i-1)];
        hr=[hr;down(i-1)];
        lr=[lr;down(i)];
        cr=[cr;down(i)];
    end
end

% -- Candlestick chart --
n = length(or); Point2End = n-1; 
candle(hr(n-Point2End:n),  lr(n-Point2End:n), cr(n-Point2End:n), or(n-Point2End:n))
    