%
%__________________________________________________________________________
%
% This function is used in the Maximium Diversified Portfolio Script
%
% DP function
%
% The DP Function is the objective function in the maximization problem in
% the MDP portfolio. 
%
% It gets as input:
% weights vector (x), 
% variance-covariance matrix (Sigma_Ptf)
% diagonal of Sigma_Ptf(Diag_Sigma). 
%
% The output is the value f computed as below:
%
%__________________________________________________________________________
%
%
function fdp = DP(x)

global SigmaMDPtf 
global DiagSigmaMDPtf

fdp = -(x' * DiagSigmaMDPtf) * (x' * SigmaMDPtf * x) ^(-0.5);