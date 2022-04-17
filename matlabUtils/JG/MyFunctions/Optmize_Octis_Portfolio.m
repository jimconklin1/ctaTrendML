%
%__________________________________________________________________________
%
% OCTIS ALLOCATION OPTIMIZER
%__________________________________________________________________________

% x = quadprog(H,f,A,b,Aeq,beq,lb,ub) returns
% a vector x that minimizes 1/2*x'*H*x + f'*x. 
% subject to the restrictions A*x < b. 
% and to the additional restrictions lb < x < ub. 
% lb and ub are vectors of doubles, and the restrictions hold for
% each x component. If no equalities exist, set Aeq = [] and beq = [].

% Fist Compute Shrinked Covariance Matrix
[sigma,shrinkage] = covMarket(jo,0);
StratCov = 12  *sigma;

%RisContrib = zeros(

% Compute Portfolio
%[ LS LF AT PT BT Der];
nbStrats = 6;

% Set of Constraints
    % -- Target Return
    %             [LS  LF  AT  PT  BT Der];
    % MeanReturns = 12 * mean(jo);
    MeanReturns = zeros(1,nbStrats);%[0.1 , 0.1 , 0.1 , 0.1 , 0.1 , 0.05];         
    % -- Equality Aeq*x = beq    
    Aineq = ones(1,nbStrats);
    bineq = 1;            
    % inequality Aineq*x <= bineq
    Aeq = ones(1,nbStrats);
    beq = 1;
    %-MeanReturns'; beq = -0;          
    % -- Lower Bounds
    lb = [0, 0, 0 , 0, 0, 0];
    % -- Upper Bounds
    ub = [1, 1, 1 , 1, 1, 0.5];
    % objective has no linear term; set
    c = zeros(nbStrats,1);                        

% Set the options to use the active-set algorithm with no display:
% options = optimset('Algorithm','active-set','Display','off');
% options = optimset(options,'Display','iter','TolFun',1e-10);
options = optimset('Algorithm','interior-point-convex');

% Call quadprog:
tic
[wgt, fval, exitflag, output, lambda] = ...
   quadprog(sigma, -MeanReturns, Aineq, bineq, Aeq, beq, lb, ub,[],options);
toc

plot(wgt)
