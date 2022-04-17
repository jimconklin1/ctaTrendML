
function [OptWgts, PortRisk, PortUtility ] = OptPortfolio(method, Alphas, ...
                                           CovMat, TargetRiskAversion, BoundThreshold)
%__________________________________________________________________________
%
% This function computes the optimum portfolio and associated metrics
% based on a quadratic optimization.
%
% note 1 : Matlab's QuadProg package :
% - minimizes the function:         0.5*x'Hx - f'x 
% - subject to the constraints:     Ax < b
%                          and      Aeqx = beq
% where H, A, and Aeq are 'k x k' square matrices 
%       and f, b and beq are 'k x 1'vectors
%       (k being the number of decision variables)
%
% note 2: As QuadProg minimizes 0.5 * x'Hx - f'x, put sign '-' (minus) in front
% of alphas!!!
%
% INPUT
%
% 'method' refers to the "direction" of the database as the code handles:
%  - "Asset in Rows & Time in Columns".
%  - "Asset in Columns & Time in Rows".
% 'method'  =   'AssetsInRows_TimeInColumns'
% 'method'  =   'TimeInRows_AssetsInColumns'
%
% Alphas = expected returns, factors ranking, etc...
% - "Asset in Rows & Time in Columns":
%                       . Alphas is a Column vector 
%                       . Optimum weights (OptWgts) is a Column Vector.
%
% - "Asset in Columns & Time in Rows":
%                       . Alphas is a Row vector 
%                       . Optimum weights (OptWgts) is a Row Vector.
%
% For a database set as 'AssetsRows_TimeColumns':
%    [OptPortWts(:,i) OptPortRisk(1,i) OptPortUtility(1,i) ] = ...
%        OptRiskAVTargeted('AssetsRows_TimeColumns', ...
%                           Alphas, ExpReturnMatrix(:,i), CovMatrix(:,:,i), 11, 1);
%
% For a database set as 'TimeRows_AssetsColumns':
%    [OptPortWts(i,:) OptPortRisk(i,1) OptPortUtility(i,1) ] = ...
%        OptRiskAVTargeted('TimeRows_AssetsColumns', ...
%                           Alphas, ExpReturnMatrix(i,:),CovMatrix(:,:,i), 11, 1);
%
% - Covariance matrix
% - Target risk aversion : impacts weights graduation (put value>10)
% - BoundThreshold
% OUPUT
% -  Optimal weights
% -  Portfolio risk
% -  Portfolio return
% -  Portfolio Utility
%__________________________________________________________________________
%warning off all;

switch method
    case 'AssetsInRows_TimeInColumns'
    % Parameters-----------------------------------------------------------
    A = ones(1,length(Alphas));
    Aeq=A;
    % Upper and Lower Bounds
    ub = ones(1,length(Alphas)) .* BoundThreshold;
    lb =  ub .* -1; %zeros(1,length(Alphas));
    % COnstant
    b = 0;  %bound for A.x
    beq=b;
    % Quadratic Optimization-----------------------------------------------
    x = quadprog(2*TargetRiskAversion*CovMat,-Alphas, A,b,Aeq,beq,lb,ub);
    %x = quadprog(CovMat,-Alphas, A,b,Aeq,beq,lb,ub);
    % Output---------------------------------------------------------------
        % Optimum weights
        OptWgts = x; 
        % Portfolio Risk
        PortRisk = sqrt(x'*CovMat*x);
        % Portfolio Return
        PortReturn = x'*Alphas;
        % Portfolio Utility
        PortUtility = PortReturn - TargetRiskAversion*(PortRisk^2);
        
    case 'TimeInRows_AssetsInColumns'
    % Parameters-----------------------------------------------------------
    % Transpose Alphas
    Alphas=Alphas';
    A = ones(1,length(Alphas));
    Aeq=A;
    % Upper and Lower Bounds
    ub = ones(1,length(Alphas)) .* BoundThreshold;
    lb =  ub .* -1; %zeros(1,length(Alphas));
    % Constant
    b = 0;  %bound for A.x
    beq=b;
    % Quadratic Optimization-----------------------------------------------
    x = quadprog(2*TargetRiskAversion*CovMat,-Alphas, A,b,Aeq,beq,lb,ub);
    %x = quadprog(CovMat,-Alphas, A,b,Aeq,beq,lb,ub);
    % Output---------------------------------------------------------------
        % Optimum weights
        OptWgts = x; 
        % Portfolio Risk
        PortRisk = sqrt(x'*CovMat*x);
        % Portfolio Return
        PortReturn = x'*Alphas;
        % Transpose Optimum weights
        OptWgts=OptWgts';        
        % Portfolio Utility
        PortUtility = PortReturn - TargetRiskAversion*(PortRisk^2); 
end