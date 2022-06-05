% this script generates optimal mean-variance frontiers

cd 'C:\GIT\RAPC\'; 
dataDir = 'M:\Manager of Managers\Hedge\quantDev\DATA\hfFactorModel\'; 
addpath 'C:\GIT\utils_ml\_data'; 

% cd 'H:\research\GIT\hfFactorModel'; 
% dataDir = 'H:\research\DATA\hfFactorModel\'; 
% addpath 'H:\research\GIT\matlabUtils\_data'; 

% mu = E[rtn], S = varcov(x)

% portfolio spec 1:
% min   x*S*x' 
% s.t.  x'mu <= mu0
%       x'1 = 1
%       0 <= x(n) <= 1, for all n

% OR portfolio spec 2:
% min  -mu*x + lambda*(x*S*x')
% s.t.
%     sum_n{ x(n)<=1 }
%     x(n) >=0, for each n
 
% transformed is
% min (x*S*x') - (1/lambda)*mu*x
% s.t.
%     sum_n{ x(n)<=1 }
%     x(n) >=0, for each n

% Matlab spec:
% [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0,options) 
%  min 0.5*(x*H*x') + f'x
%  s.t. A*x <= b
%       Aeq*x <= beq
%       lb <= x <= ub

% % portfolio spec 2:
% FIX -- wrongly specified
% x0 = [0.015, 0.015, 0.015, 0.015, 0.03, 0.01, 0.9]';
% H = (S+S')/2;
% lambda = 1.0e-2; 
% f = (1/lambda)*mu;
% A = ones(1,rrp.N); 
% b = 1; 
% lb = zeros(size(x0)); 
% ub = 0.5*ones(size(x0)); 
% [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,[],[],lb,ub,x0);

% portfolio spec 1B W/O cash:
rrp = genRiskRtnParams('liqAltNoCash');
B = rrp.fLoads;
mu = B*rrp.fErtn';
Omega = rrp.fVarCov;
S = B*Omega*B' + rrp.errCov;

mu0 = 0.025:0.001:0.054;
X = zeros(rrp.N,length(mu0)); 
portVol = zeros(1,length(mu0)); 
portErtn = zeros(1,length(mu0)); 
for i = 1:length(mu0)
    x0 = [0.015, 0.015, 0.015, 0.015, 0.03, 0.01]';
    H = (S+S')/2;
    f = zeros(size(x0')); %       i.e., min variance 
    Aeq = [mu'; ones(1,rrp.N)]; % subject to Ertn_port = constant
    beq = [mu0(i); 1];
%     A = ones(1,rrp.N);
%     b = 1;
%     Aeq = mu';
%     beq = mu0(i);
    lb = zeros(size(x0));
    ub = ones(size(x0));
    [x,fval,exitflag,output,lambda] = quadprog(H,f,[],[],Aeq,beq,lb,ub,x0);
%    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0);
    if sum(x) > 1
       x = x/sum(x);
    end
    X(:,i) = x;
    portVol(1,i) = sqrt(x'*H*x);
    portErtn(1,i) = (mu'*x);
end
%disp(100*[(mu'*x),sqrt(x'*H*x),0.01*(mu'*x)/sqrt(x'*H*x)])
figure(2)
plot(100*portVol,100*portErtn); grid; xlabel('Portfolio Volatility'); ylabel('Portfolio Expected Return'); title('Efficient Frontier, Liquid Alts')
% current portfolio:
x0 = [0.478, .2, .24, 0.07, 0, 0.012]';
a = sqrt(x0'*H*x0);
b = (mu'*x0);
disp([a,b])
c = 1;

% % portfolio spec 1A w/ cash:
% rrp = genRiskRtnParams('liqAlt');
% B = rrp.fLoads;
% mu = B*rrp.fErtn';
% Omega = rrp.fVarCov;
% S = B*Omega*B' + rrp.errCov;
% 
% mu0 = 0.002:0.001:0.054;
% X = zeros(rrp.N,length(mu0)); 
% portVol = zeros(1,length(mu0)); 
% portErtn = zeros(1,length(mu0)); 
% for i = 1:length(mu0)
%     x0 = [0.015, 0.015, 0.015, 0.015, 0.03, 0.01, 0.9]';
%     H = (S+S')/2;
%     f = zeros(size(x0'));
%     Aeq = [mu'; ones(1,rrp.N)];
%     beq = [mu0(i); 1];
%     lb = zeros(size(x0));
%     ub = ones(size(x0));
%     [x,fval,exitflag,output,lambda] = quadprog(H,f,[],[],Aeq,beq,lb,ub,x0);
%     X(:,i) = x;
%     portVol(1,i) = sqrt(x'*H*x);
%     portErtn(1,i) = (mu'*x);
% end
% %disp(100*[(mu'*x),sqrt(x'*H*x),0.01*(mu'*x)/sqrt(x'*H*x)])
% plot(portVol,portErtn)


function o = genRiskRtnParams(opt)
if strcmp(opt,'liqAlt')
    o.assetHeader = {'hfEquity','hfQuantMacro','hfEvntDr','hfOpptstc','arpPrtflo','globalEquty','cash'};
    o.factorHeader = {'globalEquty','globalCredt','globalRates','globalMtg','arpQual','arpValue','arpMom','arpLowVol','alpha'};
    o.N = size(o.assetHeader,2); 
    o.M = size(o.factorHeader,2); 
    o.fESR = [0.35, 0.3,  0.2,  0.25, 0.4,  0.4,  0.4,  0.4,   1.1]; 
    o.fEvol = [0.15, 0.02, 0.06, 0.02, 0.08, 0.08, 0.08, 0.08, 0.05]; 
    o.fErtn = o.fESR.*o.fEvol; 
    % factors:   globalEquty globalCredt globalRates globalMtg arpQual arpValue arpMom arpLowVol alpha       Assets:
    o.fLoads = [[0.5,      -0.4,       -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.6]; ... % hfEqu
                [0.15,     0.0,        -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.6]; ...  % hfQntMcr
                [0.55,     -0.25,      -0.1,        0.0,      0.0,    0.0,     0.0,   0.0,      0.5]; ... % hfEvntDr
                [0.25,     -0.1,       -0.1,        0.0,      0.0,    0.0,     0.0,   0.0,      0.65]; ...  % hfOpptnstc
                [0.0,      0.0,        0.0,         0.0,      0.25,   0.25,    0.25,  0.25,     0.0]; ...  % arpPrtflo
                [1.0,      0.0,        0.25,        -0.3,     0.0,    0.0,     0.0,   0.0,      0.0]; ...  % globEqty
                [0.0,      0.0,        0.0,         0.0,      0.0,    0.0,     0.0,   0.0,      0.0]];     % cash
    % factors:      globalEquty globalCredt globalRates globalMtg arpQual arpValue arpMom   arpLowVol alpha     
    o.fCorr = [[1.0,       0.0,        0.1,         0.0,     0.0,     0.0,     0.0,    0.0,     0.0]; ... % equ
               [0.0,       1.0,        0.0,         0.0,     0.0,     0.0,     0.0,    0.1,     0.0]; ... % crdt
               [0.1,       0.0,        1.0,         0.0,     0.1,     -0.1,    0.0,    0.2,     0.0]; ... % rates
               [0.0,       0.0,        0.0,         1.0,     0.1,     -0.1,    0.2,    0.2,     0.0]; ... % mtg
               [0.0,       0.0,        0.1,         0.1,     1.0,     0.0,     0.15    0.15,    0.0]; ... % qual
               [0.0,       0.0,        -0.1,        -0.1,    0.0,     1.0,     -0.2,   -0.15,   0.0]; ... % value
               [0.0,       0.0,        0.0,         0.2,     0.15,    -0.2,    1.0,    0.3,     0.0]; ... % mom
               [0.0,       0.1,        0.2,         0.2,     0.15,    -0.15,   0.3,    1.0,     0.0]; ... % lowVol
               [0.0,       0.0,        0.0,         0.0,     0.0,     0.0,     0.0,    0.0,     1.0]];    % alpha
    o.fVarCov = corr2cov(o.fEvol',o.fCorr); 
    o.errCov = ((0.025)^2)*eye(o.N); 
    o.errCov(o.N,o.N) = ((0.0005)^2); % variance of cash is much lower (just can't be zero)
elseif strcmp(opt,'liqAltNoCash')
    o.assetHeader = {'hfEquity','hfQuantMacro','hfEvntDr','hfOpptstc','arpPrtflo','globalEquty'};
    o.factorHeader = {'globalEquty','globalCredt','globalRates','globalMtg','arpQual','arpValue','arpMom','arpLowVol','alpha'};
    o.N = size(o.assetHeader,2); 
    o.M = size(o.factorHeader,2); 
    o.fESR = [0.35, 0.3,  0.2,  0.25, 0.4,  0.4,  0.4,  0.4, 0.75]; 
    o.fEvol = [0.15, 0.02, 0.06, 0.02, 0.08, 0.08, 0.08, 0.08, 0.05]; 
    o.fErtn = o.fESR.*o.fEvol; 
    % factors:   globalEquty globalCredt globalRates globalMtg arpQual arpValue arpMom arpLowVol alpha       Assets:
    o.fLoads = [[0.5,      -0.75,      -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.64]; ... % hfEqu
                [0.15,     0.0,        -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.6]; ...  % hfQntMcr
                [0.55,     -0.4,       -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.55]; ... % hfEvntDr
                [0.25,     -0.15,      -0.25,       0.0,      0.0,    0.0,     0.0,   0.0,      0.9]; ...  % hfOpptnstc
                [0.0,      0.0,        0.0,         0.0,      0.25,   0.25,    0.25,  0.25,     0.0]; ...  % arpPrtflo
                [1.0,      0.0,        0.25,        -0.3,     0.0,    0.0,     0.0,   0.0,      0.0]];     % globEqty
    % factors:      globalEquty globalCredt globalRates globalMtg arpQual arpValue arpMom   arpLowVol alpha     
    o.fCorr = [[1.0,       0.0,        0.1,         0.0,     0.0,     0.0,     0.0,    0.0,     0.0]; ... % equ
               [0.0,       1.0,        0.0,         0.0,     0.0,     0.0,     0.0,    0.1,     0.0]; ... % crdt
               [0.1,       0.0,        1.0,         0.0,     0.1,     -0.1,    0.0,    0.2,     0.0]; ... % rates
               [0.0,       0.0,        0.0,         1.0,     0.1,     -0.1,    0.2,    0.2,     0.0]; ... % mtg
               [0.0,       0.0,        0.1,         0.1,     1.0,     0.0,     0.15    0.15,    0.0]; ... % qual
               [0.0,       0.0,        -0.1,        -0.1,    0.0,     1.0,     -0.2,   -0.15,   0.0]; ... % value
               [0.0,       0.0,        0.0,         0.2,     0.15,    -0.2,    1.0,    0.3,     0.0]; ... % mom
               [0.0,       0.1,        0.2,         0.2,     0.15,    -0.15,   0.3,    1.0,     0.0]; ... % lowVol
               [0.0,       0.0,        0.0,         0.0,     0.0,     0.0,     0.0,    0.0,     1.0]];    % alpha
    o.fVarCov = corr2cov(o.fEvol',o.fCorr); 
    o.errCov = ((0.025)^2)*eye(o.N); 
else 
    o = NaN;
end % if
end % fn
