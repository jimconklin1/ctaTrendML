function [o, h, l, c] = BuildIRSIndex(ro, rh, rl, rc, rol, rhl, rll, rcl, mmr, dur, method)
%
%__________________________________________________________________________
%
% This function builds an interest-rate swap index.
% Several inputs are needed
%
% INPUT....................................................................
% r   = interest rate of the reference interest-rate swap
% rl1 = interest of the 1-year lower interest-rate swap for the
%       curve roll-down
% dur = duratoin of the reference interest-rate swap 
% mmr = money-market rate to compute the funding cost
% method = 2 methods are possible. Either build the interest-swap from a
% swap payer (pay the fix, receive the floating) perspective of from a swap
% receiver receiver perspecitve (receive the fix, pay the floating)
%
% OUTPUT...................................................................
% irsindex = total return interest-rate swap index
%
% METHODOLOGY..............................................................
% IRS Receiver (for 5-year IRS for e.g.)
% I(t) = I(t-1) * [ 1 - M(t) + C(t) + R(t)]
% Spot move: M(t) = (fix_5y(t) - fix_5y(t-1)) * DV01_5y(t-1)
% Carry return : C(t) = (fix_5y(t-1) - float(t-1) )/ daycount
% Rollwdown net: R(t) = (fix_5y(t) - fix_4y(t-1) )/ daycount * DV01_5y(t-1)
%
% Pay IRS
%I(t) = I(t-1) * [ 1 + M(t) - C(t) - R(t)]
%__________________________________________________________________________
%
% Identify Dimensions & Prelocate matrices---------------------------------
nsteps = length(rc);
o = zeros(nsteps,1); h = zeros(nsteps,1);
l = zeros(nsteps,1); c = zeros(nsteps,1);

%
switch method
    case {'receiver', 'rec'}
        o(1) = 100; h(1) = 100; l(1) = 100; c(1) = 100;% initialise
        for i = 2:nsteps
            % open
            o(i) = o(i-1) * ...
                         ( 1 - (ro(i) - ro(i-1))/100 * dur(i-1) ...
                           + (ro(i-1) - mmr(i-1))/100/365 + (ro(i-1) - rol(i-1))/100/365*dur(i-1) );
            % high
            h(i) = h(i-1) * ...
                         ( 1 - (rh(i) - rh(i-1))/100 * dur(i-1) ...
                           + (rh(i-1) - mmr(i-1))/100/365 + (rh(i-1) - rhl(i-1))/100/365*dur(i-1) );
            % low
            l(i) = l(i-1) * ...
                         ( 1 - (rl(i) - rl(i-1))/100 * dur(i-1) ...
                           + (rl(i-1) - mmr(i-1))/100/365 + (rl(i-1) - rll(i-1))/100/365*dur(i-1) );
            % close
            c(i) = c(i-1) * ...
                         ( 1 - (rc(i) - rc(i-1))/100 * dur(i-1) ...
                           + (rc(i-1) - mmr(i-1))/100/365 + (rc(i-1) - rcl(i-1))/100/365*dur(i-1) );                       
        end
        
    case{'payer', 'pay'}
        o(1) = 100; h(1) = 100; l(1) = 100; c(1) = 100;% initialise
        for i = 2:nsteps
            % open
            o(i) = o(i-1) * ...
                         ( 1 + (ro(i) - ro(i-1))/100 * dur(i-1) ...
                           - (ro(i-1) - mmr(i-1))/100/365 - (ro(i-1) - rol(i-1))/100/365*dur(i-1) );
            % high 
            h(i) = h(i-1) * ...
                         ( 1 + (rh(i) - rh(i-1))/100 * dur(i-1) ...
                           - (rh(i-1) - mmr(i-1))/100/365 - (rh(i-1) - rhl(i-1))/100/365*dur(i-1) );            
            % low
            l(i) = l(i-1) * ...
                         ( 1 + (rl(i) - rl(i-1))/100 * dur(i-1) ...
                           - (rl(i-1) - mmr(i-1))/100/365 - (rl(i-1) - rll(i-1))/100/365*dur(i-1) );            
            % close     
            c(i) = c(i-1) * ...
                         ( 1 + (rc(i) - rc(i-1))/100 * dur(i-1) ...
                           - (rc(i-1) - mmr(i-1))/100/365 - (rc(i-1) - rcl(i-1))/100/365*dur(i-1) );            
        end        
end
