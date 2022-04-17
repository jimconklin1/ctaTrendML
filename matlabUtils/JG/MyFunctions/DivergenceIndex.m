
function[DivInd,signLongMom] = DivergenceIndex(X,Parameters, method)
%
%__________________________________________________________________________
%
% This function compute the Divvergence Index (Lars Kestner, Quantitative
% Trading Strategies, Mc Graw Hill, Divergence Index Strategy, p. 197-203
%
% INPUT
% Parameters(1,2) = Period to compute volatility
% Parameters(1,2) = Period to compute short-term rate of change
% Parameters(1,3) = Period to compute long-term-term rate of change
% 
% OUTPUT
% Divergence Index
%
%__________________________________________________________________________
%
%
% Momentum
if strcmp(method, 'roc') || strcmp(method, 'return') 
    % Momenta
    stmom=Delta(X,'roc',Parameters(1,1));
    ltmom=Delta(X,'roce',Parameters(1,2));
    % Standard deviation
    d1rt=Delta(X,'roc',Parameters(1,3));
    std = VolatilityFunction(d1rt,'std',Parameters(1,3),Parameters(1,3),10e10);
    vol = std .* std;
elseif strcmp(method, 'delta') || strcmp(method, 'difference') || strcmp(method, 'd') || strcmp(method, 'dif') 
    % Momenta    
    stmom=Delta(X,'dif',Parameters(1,1));
    ltmom=Delta(X,'dif',Parameters(1,2));
    % Standard deviation
    d1dt=Delta(X,'dif',Parameters(1,3));
    std = VolatilityFunction(d1dt,'std',Parameters(1,3),Parameters(1,3),10e10);
    vol = std .* std;
end
    
%
% Divergence Index
DivInd=(stmom.*ltmom) ./ vol;
DivInd(DivInd==Inf)=0;
DivInd(DivInd==-Inf)=0;
signLongMom = sign(ltmom);

