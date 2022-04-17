function[upbos, downbos] =  BOS(h,l,c, method, LookbackPeriod)

%__________________________________________________________________________
%
% This function computes a breakout of range.
%
% INPUT
% h, l, c : high, low, close
% method  : thwo methods are possible
%         1. - {'close', 'c'}, the current close is compared with 
%              the maxium of the close over the lookback period
%         2. - {'high-low', 'high_low', 'h-l', 'h_l', 'hl'}, the current 
%              high (low) is compared with the maxium high (minimum low)
%              over the lookback period
% LookbackPeriod : period for Fanalysis
% OUTPUT
% upbos   : upward (bull) breakout
% downbos : downward (bear) breakout
%
% joel guglietta - March 2014
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(c);
upbos = zeros(size(c));
downbos = zeros(size(c));

for j=1:ncols
    % find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(h(i,j)) &&  ~isnan(l(i,j)) &&  ~isnan(c(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % breakout
    switch method
        case {'close', 'c'}
            if nsteps > LookbackPeriod
                for i = start_date(1,1) + LookbackPeriod + 1: nsteps
                    if c(i,j) >= max(c(i - LookbackPeriod + 1:i,j));
                       upbos(i,j) = 1;
                    end
                    if c(i,j) <= min(c(i - LookbackPeriod + 1:i,j));
                       downbos(i,j) = -1;
                    end                    
                end      
            end
        case {'high-low', 'high_low', 'h-l', 'h_l', 'hl'}
            if nsteps > LookbackPeriod
                for i = start_date(1,1) + LookbackPeriod + 1: nsteps
                    if h(i,j) >= max(h(i - LookbackPeriod+ 1:i,j));
                       upbos(i,j) = 1;
                    end
                    if l(i,j) <= min(l(i - LookbackPeriod+ 1:i,j));
                       downbos(i,j) = -1;
                    end                    
                end   
            end
    end
end

 