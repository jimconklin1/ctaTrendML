function[sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,parameters)
%__________________________________________________________________________
%
% The function computes the Stochastic Momentum Index as defined in
% "Momentum, Direction and Divergence:, William Blau, wiley, pp.25-42
%
% -- Indicator --
% It computes the "Stochastic Momentum" first (SM), then the "Stochastic
% Momentum Index" (SMI = EMA(SM, r, q)) m then the Signal Line (SSMI =
% EMA(SMI, u)).
% Stochastic Momentum = SM(q) = close - 0.5 * (HH(q) + LL(q))
% Highest High              = highest high for the look-back period "q"
% Lowest Low                = lowest low   for the look-back period "q"
% Stochastic Momentum Index = SMI(q) = 
%          100 * EMA(EMA(SM(q),r),s) / ( 0.5 * EMA(EMA(HH(q) - LL(q),r),s))
%
% -- Imput --
% Close, High, Low
% parameters(1) = look-back period for lowest low and highest high
% parameters(2) = first smoorhing period "r"
% parameters(3) = second smoorhing period "s"
% parameters(4) = signal line, smoothing period "u"
%
% -- Output --
% sm   = stochastic momentum
% smi  = stochastic momentum index
% ssmi = signal linme
%
% -- Comments --
% When the SMI is taken over a very large interval, it takes on the
% characteristics of price shape.
% Compared to the Lane's Stochastic, the SMI seems to be less noisy.
%
% Different set-ups look interesting:
% SMI(13,25,1) with signal line between 3 and 12
%     [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[13,25,1,5]);
% SMI(20,5,1) with signal line between 3 and 12
%     [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[20,5,1,5]);
% SMI(20,20,1) with signal line between 3 and 12
%     [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[20,20,1,5]);
% In particular, the 2-day SMI is promising with several set-ups:
%   - SMI(2,25,12) with signal line between 3 and 12
%     [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[2,25,12,5]);
%   - SMI(2,32,5) with signal line of 7
%     [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[2,32,5,7]);
%__________________________________________________________________________

% DIMENSION & PRELOCATE MATRIX---------------------------------------------
[nsteps,ncols] = size(c); 
midpoint = zeros(size(c));
range = zeros(size(c));
sm = zeros(size(c)); 
LookbackPeriod = parameters(1);
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
        % -- Define the range & Compute mid-point--
        MaxH = max(h(i-LookbackPeriod+1:i,j));
        MinL = min(l(i-LookbackPeriod+1:i,j));
        midpoint(i,j) = 0.5 * (MaxH + MinL);
        range(i,j) = (MaxH - MinL);
        % -- Compute KStocjastic Momentum --
        if ~isnan(midpoint(i,j)) 
            sm(i,j) = c(i,j) - midpoint(i,j);
        else
            sm(i,j) = sm(i-1,j);
        end
    end
    %
end
%
% -- Compute Stochastic Momentum Index -- 
smema = expmav(sm,parameters(2));
smema2 = expmav(smema,parameters(3));
rangeema = expmav(range,parameters(2));
rangeema2 = expmav(rangeema,parameters(3));
smi = 100 * smema2 ./ (0.5 * rangeema2);
clear smema smema2 rangeema rangeema2
% 
% -- Clean --
for j=1:ncols
    if isnan(sm(1,j)), sm(1,j) = 0; end
    if isnan(smi(1,j)), smi(1,j) = 0; end
end
for j=1:ncols
    for i=2:nsteps
        if isnan(sm(i,j)) || sm(i,j) == Inf || sm(i,j) == - Inf
            sm(i,j) = sm(i-1,j);
        end
    end
    for i=2:nsteps
        if isnan(smi(i,j)) || smi(i,j) == Inf || smi(i,j) == - Inf
            smi(i,j) = smi(i-1,j);
        end
    end    
end
%
% -- Compute Signal Line of Stochastic Momentum Index -- 
ssmi = expmav(smi, parameters(4));                 
