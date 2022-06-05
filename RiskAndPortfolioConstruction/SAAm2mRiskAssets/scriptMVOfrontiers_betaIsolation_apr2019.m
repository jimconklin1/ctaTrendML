% this script does two things:

% First, is estimates expected Sharpe ratios and core asset exposure loadings on key risk asset categories: 
%    Listed equities, private equity, hedge funds, internal absolute returns, real estate, and high yield

% Next, it uses those core asset class performance parameters to derive
%    optimal mean-variance frontiers under different assumptions

% Part 1: estimate core asset class performance parameters
cd 'C:\GIT\RAPC\'; 
dataDir = 'M:\Manager of Managers\Hedge\quantDev\DATA\RAPC\'; 
addpath 'C:\GIT\utils_ml\_data'; 

load 'M:\Manager of Managers\Hedge\quantDev\DATA\RAPC\histAltBMdata.mat' altBMdata; 
dHeader = altBMdata.header; 
tmpRtns = altBMdata.values(:,1:end-1); 
RFR = altBMdata.values(:,end); 
tmpRFR = repmat(RFR,[1,size(tmpRtns,2)]); 
xsRtns2yr = 4*tmpRtns(end-23:end,:) - 4*tmpRFR(end-23:end,:); % convert quarterly units to annual units and measure excess returns
xsRtns5yr = 4*tmpRtns(end-59:end,:) - 4*tmpRFR(end-59:end,:); 
xsRtnsFull = 4*tmpRtns - 4*tmpRFR; 
ExsRtn = (0.334*nanmean(xsRtns2yr)+0.333*nanmean(xsRtns5yr)+0.334*nanmean(xsRtnsFull));
S = (0.334*nancov(xsRtns2yr)+0.333*nancov(xsRtns5yr)+0.333*nancov(xsRtnsFull)); % var cov matrix
[vol, corr] = cov2corr(S);

% derive out-of-sample betas:
[T,N] = size(tmpRtns);
betas = zeros(T,N);
omega = zeros(T,N,N); 
seedRtns = tmpRtns(1:40,:);
[~,tmpC] = cov2corr(nancov(seedRtns)); %tmpC = corrcoef(seedRtns);
% Note: MSCI world rtns are in column 3
betas(40,:) = tmpC(3,:).*nanstd(seedRtns)./repmat(nanstd(seedRtns(:,3)),[1,size(seedRtns,2)]);
omega(40,:,:) = nancov(seedRtns);
betas(1:39,:) = repmat(betas(40,:),[39,1]); 
omega(1:39,:,:) = repmat(omega(40,:,:),[39,1,1]);
for t = 41:T
   seedRtns = tmpRtns(1:t,:);
   omega(t,:,:) = nancov(seedRtns);
   [~,tmpC] = cov2corr(nancov(seedRtns)); %corrcoef(seedRtns);
   betas(t,:) = tmpC(3,:).*nanstd(seedRtns)./repmat(nanstd(seedRtns(:,3)),[1,size(seedRtns,2)]);
end 

% Create standard asset property table:
%            Ertn    ESR      Evol     eqBeta    liqMat   trnspcyScr   histRtn    histSR   histVol  
% Equities
% PE
% HY
% RE
% HF
% ARP

% NOTE: Simulation 1: using benchmarks; e.g., MSCI, HFRX for HF returns, etc.
port1.dataIndx = [3,1,6,7,5,8]; % data header sequence: {'PE','histHF','MSCIworld','histHFalpha','HFRX','HY','RE','ARPequ','LIBOR'}
                               % port header sequence: Equities, PE, HY, RE, HF, ARP
port1.header = {'equity','PE','HY','GRE','HF','ARP'}; 
port1.flds = {'Ertn','ESR','Evol','eqBeta','lqdtyMtrty','trnspcyScr','histRtn','histSR','histVol'}; 
port1.params = zeros(6,9);
% generic data assignments:
%                   equity PE     HY    RE     HF    ARP
port1.params(:,2) = [0.35, 0.67, 0.5,   0.6,  0.8,  0.5]'; % E_SR
port1.params(:,3) = [0.15, 0.15, 0.075, 0.12, 0.04, 0.15]'; % E_vol
port1.params(:,1) = port1.params(:,2).*port1.params(:,3) + repmat(4*RFR(end,1),[6,1]); % E_returns -- add LIBOR back in
port1.params(:,5) = [3/260, 6, 3/260, 6, 0.4, 3/260]'; % liquidity maturity, in yrs
port1.params(:,6) = [10,2,10,7,2,9]'; % transparency score

port1.params(:,4) = betas(end,port1.dataIndx)';
port1.params(:,7) = 4*nanmean(tmpRtns(:,port1.dataIndx)); % historical returns
port1.params(:,9) = 2*nanstd(tmpRtns(:,port1.dataIndx)); % historical vol
port1.params(:,8) = (port1.params(:,7)-repmat(4*nanmean(RFR),[6,1]))./port1.params(:,9); % historical Sharpe
port1.VCV = squeeze(omega(end,port1.dataIndx,port1.dataIndx)); 
portTable1 = array2table(port1.params,'RowNames',port1.header,'VariableNames',port1.flds); 

% map portfolio primitives into MVFrontier variables:
header = port1.header;
Ertn = port1.params(:,7); % Use historical SRs for first MVO 
N = length(Ertn);
S = port1.VCV; 
for i = 1:N; S(i,i) = port1.params(i,3)^2; end % replace historical variances w/ expected variances

% now deriv MV frontier:
mu0 = 0.015:0.001:0.12;
X = zeros(N,length(mu0)); 
portVol = zeros(1,length(mu0)); 
portErtn = zeros(1,length(mu0)); 
portAUM = zeros(1,length(mu0)); 
portBeta = zeros(1,length(mu0)); 
x0 = repmat(1/N,[1,N]);
H = (S+S')/2; % make sure VCV is perfectly symmetric (so that precision inaccuracies don't create erroneous asymmetry)
for i = 1:length(mu0)
    f = zeros(size(x0'));    %       i.e., min variance 
    A = [-Ertn'; ones(1,N)]; %       subject to Ertn_port = constant
    b = [-mu0(i); 1];
    lb = zeros(size(x0));
    ub = ones(size(x0));
    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,[],[],lb,ub,x0);
%    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0);
    if sum(x) > 1
       x = x/sum(x);
    end
    X(:,i) = x;
    portVol(1,i) = sqrt(x'*H*x);
    portErtn(1,i) = (Ertn'*x);
    portAUM(1,i) = sum(x);
    portBeta(1,i) = port1.params(:,4)'*x;
end
x_lr = [0,     0.077, (0.329+0.428), 0.11,  0.056, 0]';
x_gi = [0.054, 0.137, (0.197+0.142), 0.182, 0.288, 0]';
exRtn_lr = Ertn'*x_lr;
exVol_lr = sqrt(x_lr'*H*x_lr);
lrPort = nan(2,length(portErtn));
lrPort(:,1) = [exVol_lr;exRtn_lr];
exRtn_gi = Ertn'*x_gi;
exVol_gi = sqrt(x_gi'*H*x_gi);
giPort = nan(2,length(portErtn));
giPort(:,1) = [exVol_gi;exRtn_gi];

outputTable1 = array2table([portErtn',portVol',portErtn'./portVol',portAUM',portBeta',X'],'VariableNames',[{'Ertn','Evol','Esr','aum','beta'},header]);
xx = [100*portVol',100*portErtn']; figure(1)
plot(xx(:,1),xx(:,2)); grid; xlabel('Portfolio Volatility'); ylabel('Portfolio Expected Return'); title('Efficient Frontier, Risk assets, Scenario 1')

% Case 2: use assumed asset class parameters; for HF, use target portfolioe.g., alpha only (estimated w/ historical returns) and lower beta 
port2.header = {'equity','PE','HY','GRE','HF','ARP'}; 
port2.dataIndx = [3,1,6,7,4,8]; % data header sequence: {'PE','histHF','MSCIworld','histHFalpha','HFRX','HY','RE','ARPequ','LIBOR'}
                                % port header sequence: Equities, PE, HY, RE, HF, ARP
port2.flds = {'Ertn','ESR','Evol','eqBeta','lqdtyMtrty','trnspcyScr','histRtn','histSR','histVol'}; 
port2.params = zeros(6,9); 
%                   equity PE     HY    RE     HF    ARP
port2.params(:,2) = [0.35, 0.67,  0.5,  0.6,  0.8,  0.5]'; % E_SR
port2.params(:,3) = [0.15, 0.15, 0.075, 0.12,  0.04, 0.15]'; % E_vol
port2.params(:,1) = port1.params(:,2).*port1.params(:,3) + repmat(4*RFR(end,1),[6,1]); % E_returns -- add LIBOR back in
port2.params(:,5) = [3/260, 6, 3/260, 6, 1.1, 3/260]'; % liquidity maturity, in yrs
port2.params(:,6) = [10,2,10,7,2,9]'; % transparency score

port2.params(:,4) = betas(end,port2.dataIndx)';
port2.params(:,7) = 4*nanmean(tmpRtns(:,port2.dataIndx)); % historical returns
port2.params(:,9) = 2*nanstd(tmpRtns(:,port2.dataIndx)); % historical vol
port2.params(:,8) = (port2.params(:,7)-repmat(4*RFR(end,1),[6,1]))./port2.params(:,9); % historical Sharpe
port2.VCV = squeeze(omega(end,port2.dataIndx,port2.dataIndx));
portTable2 = array2table(port2.params,'RowNames',port2.header,'VariableNames',port2.flds); 

% map portfolio primitives into MVFrontier variables:
header = port2.header;
Ertn = port2.params(:,1); 
N = length(Ertn);
[~,tmpCorr] = cov2corr(port2.VCV); 
volMat = repmat(port2.params(:,3),[1,size(tmpCorr,2)]);
S = tmpCorr.*(volMat.*volMat');

% now deriv MV frontier:
mu0 = 0.015:0.001:0.11;
X = zeros(N,length(mu0)); 
portVol = zeros(1,length(mu0)); 
portErtn = zeros(1,length(mu0)); 
portAUM = zeros(1,length(mu0)); 
portBeta = zeros(1,length(mu0)); 
x0 = repmat(1/N,[1,N]);
H = (S+S')/2; % make sure VCV is perfectly symmetric (so that precision inaccuracies don't create erroneous asymmetry)
for i = 1:length(mu0)
    f = zeros(size(x0'));    %       i.e., min variance 
    A = [-Ertn'; ones(1,N)]; %       subject to Ertn_port = constant
    b = [-mu0(i); 1];
    lb = zeros(size(x0));
    ub = ones(size(x0));
    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,[],[],lb,ub,x0);
%    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0);
    if sum(x) > 1
       x = x/sum(x);
    end
    X(:,i) = x;
    portVol(1,i) = sqrt(x'*H*x);
    portErtn(1,i) = (Ertn'*x);
    portAUM(1,i) = sum(x);
    portBeta(1,i) = port2.params(:,4)'*x;
end 
outputTable2 = array2table([portErtn',portVol',portErtn'./portVol',portAUM',portBeta',X'],'VariableNames',[{'Ertn','Evol','Esr','aum','beta'},header]);
xx = [100*portVol',100*portErtn']; figure(2)
plot(xx(:,1),xx(:,2)); grid; xlabel('Portfolio Volatility'); ylabel('Portfolio Expected Return'); title('Efficient Frontier, Risk assets, Scenario 2')

exRtn_lr = Ertn'*x_lr;
exVol_lr = sqrt(x_lr'*H*x_lr);
exRtn_gi = Ertn'*x_gi;
exVol_gi = sqrt(x_gi'*H*x_gi);

% Case 3: set-up of case 2 PLUS capital constraints 
port3.header = {'equity','PE','HY','GRE','HF','ARP'}; 
port3.dataIndx = [3,1,6,7,4,8]; % data header sequence: {'PE','histHF','MSCIworld','histHFalpha','HFRX','HY','RE','ARPequ','LIBOR'}
                                % port header sequence: Equities, PE, HY, RE, HF, ARP
port3.flds = {'Ertn','ESR','Evol','eqBeta','lqdtyMtrty','trnspcyScr','histRtn','histSR','histVol'}; 
port3.params = zeros(6,9); 
port3.params(:,2) = [0.35, 0.67,  0.5,  0.6,  0.8,  0.5]'; % E_SR
port3.params(:,3) = [0.15, 0.15, 0.075, 0.12,  0.04, 0.15]'; % E_vol
port3.params(:,1) = port1.params(:,2).*port1.params(:,3) + repmat(4*RFR(end,1),[6,1]); % E_returns -- add LIBOR back in
port3.params(:,5) = [3/260, 6, 3/260, 6, 1.1, 3/260]'; % liquidity maturity, in yrs
port3.params(:,6) = [10,2,10,7,2,9]'; % transparency score

port3.params(:,4) = betas(end,port3.dataIndx)';
port3.params(:,7) = 4*nanmean(tmpRtns(:,port3.dataIndx)); % historical returns
port3.params(:,9) = 2*nanstd(tmpRtns(:,port3.dataIndx)); % historical vol
port3.params(:,8) = (port3.params(:,7)-repmat(4*RFR(end,1),[6,1]))./port3.params(:,9); % historical Sharpe
port3.VCV = squeeze(omega(end,port3.dataIndx,port3.dataIndx));
portTable3 = array2table(port3.params,'RowNames',port3.header,'VariableNames',port3.flds); 

% map portfolio primitives into MVFrontier variables:
header = port3.header;
Ertn = port3.params(:,1); 
N = length(Ertn);
[~,tmpCorr] = cov2corr(port3.VCV); 
volMat = repmat(port3.params(:,3),[1,size(tmpCorr,2)]);
S = tmpCorr.*(volMat.*volMat');
liqVec = port3.params(:,5)'; 
avgLiqPort = 2.0;
liq1MoPercPort = 0.15;
avgLiq_lr = liqVec*x_lr; %#ok<NASGU>
avgLiq_gi = liqVec*x_gi; %#ok<NASGU>

% now deriv MV frontier:
mu0 = 0.015:0.001:0.11;
X = zeros(N,length(mu0)); 
portVol = zeros(1,length(mu0)); 
portErtn = zeros(1,length(mu0)); 
portAUM = zeros(1,length(mu0)); 
portBeta = zeros(1,length(mu0)); 
x0 = repmat(1/N,[1,N]);
H = (S+S')/2; % make sure VCV is perfectly symmetric (so that precision inaccuracies don't create erroneous asymmetry)
for i = 1:length(mu0)
    f = zeros(size(x0'));    %       i.e., min variance subject to Ertn_port = constant
    A = [-Ertn'; 
         liqVec; 
         -(portTable3.lqdtyMtrty < 1/12)'; 
         ones(1,N)]; %       
    b = [-mu0(i); avgLiqPort; -liq1MoPercPort; 1];
    lb = zeros(size(x0));
    ub = ones(size(x0));
    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,[],[],lb,ub,x0);
%    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0);
    if sum(x) > 1
       x = x/sum(x);
    end
    X(:,i) = x;
    portVol(1,i) = sqrt(x'*H*x);
    portErtn(1,i) = (Ertn'*x);
    portAUM(1,i) = sum(x);
    portBeta(1,i) = port3.params(:,4)'*x;
end 
outputTable3 = array2table([portErtn',portVol',portErtn'./portVol',portAUM',portBeta',X'],'VariableNames',[{'Ertn','Evol','Esr','aum','beta'},header]);
xx = [100*portVol',100*portErtn']; figure(3)
plot(xx(:,1),xx(:,2)); grid; xlabel('Portfolio Volatility'); ylabel('Portfolio Expected Return'); title('Efficient Frontier, Risk assets, Scenario 3')

disp(xx) 
disp(outputTable3)

% Case 4: set-up of case 2 PLUS capital constraints 
port4.header = {'equity','PE','HY','GRE','HF','ARP'}; 
port4.dataIndx = [3,1,6,7,4,8]; % data header sequence: {'PE','histHF','MSCIworld','histHFalpha','HFRX','HY','RE','ARPequ','LIBOR'}
                                % port header sequence: Equities, PE, HY, RE, HF, ARP
port4.flds = {'Ertn','ESR','Evol','eqBeta','lqdtyMtrty','trnspcyScr','histRtn','histSR','histVol','rbc','intrlCptl'}; 
port4.params = zeros(6,9); 
%                   equity PE     HY    RE     HF    ARP
port4.params(:,2) = [0.35, 0.67,  0.5,  0.67,  0.75,  0.5]'; % E_SR
port4.params(:,3) = [0.15, 0.15, 0.075, 0.12,  0.04, 0.15]'; % E_vol
port4.params(:,1) = port1.params(:,2).*port1.params(:,3) + repmat(4*nanmean(RFR),[6,1]); % E_returns -- add LIBOR back in
port4.params(:,4) = betas(end,port4.dataIndx)';

port4.params(:,5) = [3/260, 6, 3/260, 6, 0.4, 3/260]'; % liquidity maturity, in yrs
port4.params(:,6) = [10,2,10,7,2,9]'; % transparency score 

port4.params(:,7) = 4*nanmean(tmpRtns(:,port4.dataIndx)); % historical returns
port4.params(:,9) = 2*nanstd(tmpRtns(:,port4.dataIndx)); % historical vol
port4.params(:,8) = (port4.params(:,7)-repmat(4*nanmean(RFR),[6,1]))./port4.params(:,9); % historical Sharpe
port4.params(:,10) = [0.0354, 0.0354, .1, .1852, 0.0354, .2416]; % RBC capital charges
port4.params(:,11) = [.505, .328, .2336, .478, .338, .338]; % Internal capital charges
port4.VCV = squeeze(omega(end,port4.dataIndx,port4.dataIndx));
portTable4 = array2table(port4.params,'RowNames',port4.header,'VariableNames',port4.flds); 

% map portfolio primitives into MVFrontier variables:
header = port4.header;
Ertn = port4.params(:,1); 
N = length(Ertn);
[~,tmpCorr] = cov2corr(port4.VCV); 
volMat = repmat(port4.params(:,3),[1,size(tmpCorr,2)]);
S = tmpCorr.*(volMat.*volMat');
liqVec = port4.params(:,5)'; 
avgLiqPort = 1.5;
rbcVec = port4.params(:,10)';
avgRbc = 0.08;
intCapVec = port4.params(:,11)';
avgIntCap = 0.32;
avgLiq_lr = liqVec*x_lr;
avgLiq_gi = liqVec*x_gi;
avgRbc_lr = rbcVec*x_lr;
avgRbc_gi = rbcVec*x_gi;
avgIntCap_lr = intCapVec*x_lr;
avgIntCap_gi = intCapVec*x_gi;

% now deriv MV frontier:
mu0 = 0.015:0.001:0.10;
X = zeros(N,length(mu0)); 
portVol = zeros(1,length(mu0)); 
portErtn = zeros(1,length(mu0)); 
portAUM = zeros(1,length(mu0)); 
portBeta = zeros(1,length(mu0)); 
x0 = repmat(1/N,[1,N]);
H = (S+S')/2; % make sure VCV is perfectly symmetric (so that precision inaccuracies don't create erroneous asymmetry)
for i = 1:length(mu0)
    f = zeros(size(x0'));    %       i.e., min variance subject to Ertn_port = constant
    A = [-Ertn'; rbcVec; intCapVec; ones(1,N)]; %       
    b = [-mu0(i); avgRbc; avgIntCap; 1];
    lb = zeros(size(x0));
    ub = ones(size(x0));
    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,[],[],lb,ub,x0);
%    [x,fval,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq,lb,ub,x0);
    if sum(x) > 1
       x = x/sum(x);
    end
    X(:,i) = x;
    portVol(1,i) = sqrt(x'*H*x);
    portErtn(1,i) = (Ertn'*x);
    portAUM(1,i) = sum(x);
    portBeta(1,i) = port4.params(:,4)'*x;
end 
outputTable4 = array2table([portErtn',portVol',portErtn'./portVol',portAUM',portBeta',X'],'VariableNames',[{'Ertn','Evol','Esr','aum','beta'},header]);
xx = [100*portVol',100*portErtn']; figure(4)
plot(xx(:,1),xx(:,2)); grid; xlabel('Portfolio Volatility'); ylabel('Portfolio Expected Return'); title('Efficient Frontier, Risk assets, Scenario 4')

disp(xx) 
disp(outputTable4)

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
% Part 2: efficient frontiers
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
%       Aeq*x = beq
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
% rrp = genRiskRtnParams('liqAltNoCash');
% B = rrp.fLoads;
% S = B*Omega*B' + rrp.errCov;
