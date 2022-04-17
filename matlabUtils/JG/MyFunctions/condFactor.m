%
%__________________________________________________________________________
%
% Extract a set of confitions for 
% 4 methods:
% - {'pastvalue2max', 'pv2max'} : pastVector > Threshold
% - {'pastvalue2min', 'pv2min'} : pastVector < Threshold
% - {'nowHigherpastvalue', 'nhpv'} : Now > Past vector
% - {'nowLigherpastvalue', 'nlpv'} : Now < Past vector
% Input:
% paramters(1,1): lookback 
% parameters(1,2): lag (usually -1)
% parameters(1,3): threshold (only for first wo methods)
%
%__________________________________________________________________________
%
%
function y = condFactor(x, method, parameters)

[nsteps,ncols]= size(x);
y = zeros(size(x));

for j=1:ncols
    
    xsnap = x(:,j);

    tsStart = StartFinder(xsnap, 'znan');
    
    lookback = parameters(1,1);
    lag = parameters(1,2);
    
    for i= tsStart + lookback + lag: nsteps
        
        xsnapLookback = xsnap(i-lookback-lag:i-lag);      
        
        switch method
            
            case {'pastvalue2max', 'pv2max'}
                threshold = parameters(1,3);
                dv = xsnapLookback - repmat(threshold, size(xsnapLookback,1), 1);                  
                sdv = sign(sum(dv>0));
                y(i,j) = sdv;
            case {'pastvalue2min', 'pv2min'}
                threshold = parameters(1,3);
                dv = xsnapLookback - repmat(threshold, size(xsnapLookback,1), 1);                  
                sdv = sign(sum(dv<0));
                y(i,j) = sdv;     
            case {'nowHigherpastvalue', 'nhpv'}
                dv = repmat(xsnap(i), size(xsnapLookback,1), 1) - xsnapLookback;
                sdv = sign(sum(dv>0));
                y(i,j) = sdv;                   
            case  {'nowLigherpastvalue', 'nlpv'}
                dv = repmat(xsnap(i), size(xsnapLookback,1), 1) - xsnapLookback;
                sdv = sign(sum(dv<0));
                y(i,j) = sdv;                   
        end
    end
end