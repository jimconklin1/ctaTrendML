function[macdg, macds, macdd, fmacdd, smacdd, macdgn, macddn] = ...
    MACDFunction(x, method, PeriodFast, PeriodSlow, PeriodSignal,...
                 SmoothHisto, PeriodNormalisation)

%__________________________________________________________________________
%
% This function computes the Moving Average Convergence / Divergence index,
% (MACD, created by Gerald Appel in the late 1970s), its signal and 
% normalised (volatility based) value.
% 
% note: it makes use of the function "volatility" which computes the
% tandard deviation on a rolling basis.
%
% -- INPUT --
% X                   = close price
% 'method'            = if there is no 0 element the normalisation works
%                       fast as the macro does not divide by 0. If there is
%                       some 0 elements, it works more slowly.
%                       - method = 'with 0' means that there is some 0
%                       elements in the data base.
%                       - method = 'without 0' means that there is no 0
%                       element in the data base.
% PeriodFast          = period for Fast moving average
% PeriodSlow          = period for Slow moving average
% PeriodSignal        = period for the signal (double smoothing)
% PeriodNormalisation = period for normalisation
% SmoothHisto         = Fast [SmoothHisto(1,1)]& Slow[SmoothHisto(1,2)] 
% -- Usual set-ups:
%	- Fast version (6-19-9)
%   function[macdg, macds, macdd, fmacdd, smacdd, macdgn, macddn] = ...
%                                   MACDFunction(c,'w0',6,19,9,[3,13],20)
%	- Buy version (12-26-9, the Bloomberg default version)
%   function[macdg, macds, macdd, fmacdd, smacdd, macdgn, macddn] = ...
%                                   MACDFunction(c,'w0',12,26,9,[3,13],20)
%	- Sell version (19-39-9, Chris Roberts' chosen version)
%   function[macdg, macds, macdd, fmacdd, smacdd, macdgn, macddn] = ...
%                                   MACDFunction(c,'w0',19,39,9,[3,13],20)
%
% -- OUTPUT --
% -- Textbook outputs --
% Gross MACD = macdg = Fast Ex. Mov. Avg. - Slow Ex. Mov. Avg.
% Signal MACD = macds = expmav(macdg,PeriodSignal);
% Differenced MACD (Histogramm) = macdd = Gross MACD - Signal MACD
% -- Added outputs --
% Fast (fmacdd) & Slow (smacdd) exp. moving averages of 'macdd'
% Standardised macdg = macdgn = macdg / std.dev(macdg)
% Standardised macdd = macddn = macdd / std.dev(macdd)
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
[nsteps,ncols] = size(x);

% Gross MACD (difference in Exp. Moving Averages)--------------------------
macdg = expmav(x,PeriodFast) - expmav(x,PeriodSlow);
% Clean up to PeriodSlow
macdg(1:PeriodSlow,:) = zeros(PeriodSlow,ncols);

% MACD Signal: Moving average of the gross MACD----------------------------
macds = expmav(macdg,PeriodSignal);

% Histogramm (detrended) MACDG  = MACD gross - MACD Signal-----------------
macdd = macdg - macds;
% Smooth MACDD-------------------------------------------------------------
fmacdd = expmav(macdd,SmoothHisto(1,1));
smacdd = expmav(macdd,SmoothHisto(1,2));

% Normalisation Gross MACD-------------------------------------------------
    % Volatility of Gross MACD
    macdgv = VolatilityFunction(macdg,'std',...
        PeriodNormalisation,PeriodNormalisation,1);
    % Normalized Gross MACD
    switch method
        case {'without 0', 'without0', 'wo0','w/o0'}
            macdgn = macdg ./ macdgv;
        case {'with 0','with0','w0'}
            macdgn = zeros(size(x));
            for i = 2:nsteps
                for j=1:ncols
                    if macdgv(i,j) ~= 0
                       macdgn(i,j) = macdg(i,j) / macdgv(i,j);
                    else
                        if macdgv(i-1,j) ~= 0
                            macdgv(i,j) = macdgv(i-1,j);
                            macdgn(i,j) = macdg(i,j) / macdgv(i,j);
                        end                       
                    end
                end
            end
    end
%
% Normalisation of Histogramm MACDD----------------------------------------
    % Volatility of the of the Histogramm (detrended MACDG) MACD
    macddv = VolatilityFunction(macdd,'std',...
        PeriodNormalisation,PeriodNormalisation,1);
    % Normmalized MACD Signal
    switch method
        case {'without 0', 'without0', 'wo0','w/o0'}   
            macddn = macdd ./ macddv;
        case {'with 0','with0','w0'}
            macddn = zeros(size(x));
            for i = 2:nsteps
                for j=1:ncols
                    if macddv(i,j) ~= 0
                       macddn(i,j) = macdd(i,j) / macddv(i,j);
                    else
                        if macddv(i-1,j) ~= 0
                            macddv(i,j) = macddv(i-1,j);
                            macddn(i,j) = macdd(i,j) / macddv(i,j);
                        end
                    end
                end
            end
    end            