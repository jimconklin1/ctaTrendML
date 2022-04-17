function [signal ,signalCube]= MMAsignals(prices,rtns,lookbackPairs,MAwts)
% This function calculates the moving average signal across different
% zones weighted by the weights assigned to each zone.

% checking to see if all the arguments are there
if (nargin < 4)
    error('Bad number of arguments');
end 

% checking to make sure sum of weights is 1
if round(sum(MAwts)) ~= 1
    error('Sum of zone weights should add up to 1');
end 
    
[T,N] = size(prices); 
K = length(MAwts); 

% find universe of lookbacks
lookbacks= unique (lookbackPairs); 

% compute weighted combination of MA cross-over signals:
signalCube = zeros(T,N,K); 
signal = zeros(T,N);
for n = 1:N
    % compute moving average for our universe of looksbacks
    MAs = nan(length(prices(:,n)), length(lookbacks));
    for i=1:length(lookbacks)
        MAs(:, i) = calcMA(prices(:,n), lookbacks(i));
    end % for i
    
    % make sure that weights across all MAs add up to 1
    MAwts = MAwts/sum(MAwts);
    
    % compute signals based on moving average combinations
    for i = 1:length(lookbackPairs)
        lb1 = lookbacks==lookbackPairs(i,1);
        lb2 = lookbacks==lookbackPairs(i,2);
        signalCube(:,n,i) = sign(MAs(:, lb1) - MAs(:, lb2)); 
        signal(:,n) = signal(:,n) +  MAwts(i)*(sign(MAs(:, lb1) - MAs(:, lb2)));
    end % for i 
end % for n 
  
end % fn
