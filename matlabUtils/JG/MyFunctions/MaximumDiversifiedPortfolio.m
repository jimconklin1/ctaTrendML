%
%__________________________________________________________________________
%
%                       Maximum Diversified Portfolio
%
% This script makes use of 3 functions:
% - DP;
% - lmom;
% - LegendreShiftPoly
%
%__________________________________________________________________________

global Sigma_Ptf Diag_Sigma
k=100;                          % the initial capital value of investing
[nsteps, ncols] = size(y);
l = 1;
Sigma_Ptf = cov(y);
Diag_Sigma = diad(Sigma_Ptf);
Aeq = ones(ncols,1)';
beq = 1;                        % the right hand side of the equality constraint
lb = zeros(ncols, 1);           % the lower bound
ub = lb + Inf;                  % the upper bound

x0 = lb + 1/(ncols);            % the initial value of the iterations

omega_MDP = fmincon(@DP, x0, [], [], Aeq, beq, lb, ub);
% Minimizes fun object to the linear equalities Aeq * x = beq and 
%                                               A * x > b.
% If no inequalities exist, set A = [] and b =[].

% Prelocate matrices
v = zeros(1,ncols);
nr = zeros(1,ncols);
Ret_port_MDP = zeros(1,ncols);
Return_MDP = zeros(1,ncols);

for i=2:nsteps
    for j=1:ncols
        v(j) = omega_MDP(j) * k;            % computes the value of each
                                            % fund giving the corresponding 
                                            % weight
        nr(j) = v(j) / X(i,j);              % computes the number of such 
                                            % shares one can buy with the 
                                            % given money k
        k = k + (X(i,j) - X(i-1,j)) * nr(j);% computes the returns of the 
                                            % investment
    end
    Ret_port_MDP(l) = k;% the vector of the index value of the MDP portfolio
    l = l + 1;
end
i = 1;
for l=2:ncols
    Return_MDP(i) = (Ret_port_MDP(l) - Ret_port_MDP(l-1)) / Ret_port_MDP(l-1);
    % the returns of the MDP Portfolio
    i = i + 1;
end
sharpe(Return_MDP);                         % The Sharpe ratio
lmom(Return_MDP,4);                         % The first four L_moments

