%
%__________________________________________________________________________
% Maximum Diversification Risk Portfolio fitness function.
%
% Objective function
% P is a portoflio
% Q is the covariance matrix
% Diaq(Q) is the diagonal matrix of Q, i.e. the variance
% s is N-by-1 column vector of standard deviations, 
% s = diag(Q)^0.5
% Ws are the weigths
%
% Robert Clarke (2001): the objective function in the Maximium
% Diversification portfolio is the "Diversification ratio" (p.30)
% D(P) = W' s / (W'QW)^0.5
%
% Looking at this equation, it has the form of the Sharpe ratio where the
% volatility vector s replaces the the expected excess returns vector.
% Wit S_MD, the variance of the variance of the Maximum Diversification
% portoflio, the optimal Diversification weight vector is
% W_MD = S_MD / s_A * Inv(Q) s
%
% I am injecting this function into fmincon 
% Therefore I put sign "-" in front of the function
%
%__________________________________________________________________________

function fval = fm_fitnessMDR(covMat, x) 

    % Extract sigma
    sigmaVector = sqrt(diag(covMat));
    % Obejective function
    fval = -(x' * sigmaVector) / ( (x' * covMat * x) ^0.5 );
