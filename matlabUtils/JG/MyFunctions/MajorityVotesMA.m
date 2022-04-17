function  y = MajorityVotesMA(c, Lookbacks, method)
%
%__________________________________________________________________________
%
% This function compute the majority votes (as an average) of the trading
% signals veruss a set of moving averages
%
%__________________________________________________________________________
%
[nsteps, ncols]=size(c);
LookbacksNb = length(Lookbacks); % number of parameters
cubema = zeros(nsteps, ncols, LookbacksNb);
y = zeros(size(c));

for u=1:LookbacksNb 
    % COmpute moving average
    switch method
        case {'ama', 'amav', 'ma', 'sma', 'arithmetic' }
            c2ma = sign(c-arithmav(c,Lookbacks(1,u)));
        case {'ema', 'emav', 'expma', 'expmav', 'exponential'}
            c2ma = sign(c-expmav(c,Lookbacks(1,u)));
        case {'tma',  'tmav', 'triangma', 'triangular',}
            c2ma = sign(c-triangularmav(c,Lookbacks(1,u)));
    end
    % Assign to cube
    cubema(:,:,u) = c2ma(:,:);
end

% Compute moving average of sign
for i=1:nsteps
    for j=1:ncols
        y(i,j) = mean(cubema(i,j,:));
    end
end
