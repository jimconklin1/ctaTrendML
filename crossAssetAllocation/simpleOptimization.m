function w = simpleOptimization()

% inputs:
p1.Ertn = [0.0365	0.0778	0.0928	0.0531	0.0801	0.0271	0.0271]'; % JPM
p1.Evol = [0.1412	0.1743	0.2167	0.1313	0.220141576	0.0664	0.0664]'; 
p1.Ecorr = [[1	    0.74	0.74	0.51	0.51	0.71 	0.00]; ...
            [0.74	1	    0.90	0.50	0.50	0.78	0.00]; ...
            [0.74	0.90	1	    0.50	0.50	0.78	0.00]; ...
            [0.51	0.50	0.50	1	    0.90	0.57	0.00]; ...
            [0.51	0.50	0.50	0.90	1	    0.57	0.00]; ...
            [0.71	0.78	0.78	0.57	0.57	1	    0.00]; ...
            [0.00	0.00	0.00	0.00	0.00	0.00	1]];

p2.Ertn = [0.064	0.185	0.2	0.062	0.087	0.048	0.0271]'; % BLK
p2.Evol = [0.168	0.32	0.34	0.123	0.1599	0.078	0.0664]';
p2.Ecorr = [[1	    0.74	0.74	0.51	0.51	0.71 	0.00]; ...
            [0.74	1	    0.90	0.50	0.50	0.78	0.00]; ...
            [0.74	0.90	1	    0.50	0.50	0.78	0.00]; ...
            [0.51	0.50	0.50	1	    0.90	0.57	0.00]; ...
            [0.51	0.50	0.50	0.90	1	    0.57	0.00]; ...
            [0.71	0.78	0.78	0.57	0.57	1	    0.00]; ...
            [0.00	0.00	0.00	0.00	0.00	0.00	1]];

p3.Ertn = [0.064	0.1053	0.1203	0.05755	0.086812712	0.03755	0.03755]'; % GAAP
p3.Evol = [0.168	0.1     0.11	0.078	0.117661017	0.0722	0.0722]'; 
p3.Ecorr = [[1	    0.74	0.74	0.51	0.51	0.71 	0.00]; ...
            [0.74	1	    0.90	0.50	0.50	0.78	0.00]; ...
            [0.74	0.90	1	    0.50	0.50	0.78	0.00]; ...
            [0.51	0.50	0.50	1	    0.90	0.57	0.00]; ...
            [0.51	0.50	0.50	0.90	1	    0.57	0.00]; ...
            [0.71	0.78	0.78	0.57	0.57	1	    0.00]; ...
            [0.00	0.00	0.00	0.00	0.00	0.00	1]];

p4.Ertn = [0.064	0.1053	0.1203	0.05755	0.086812712	0.03755	0.03755]'; % Fin Supp
p4.Evol = [0.0586	0.1     0.11	0.078	0.117661017	0.0722	0.0722]'; 
p4.Ecorr = [[1	    0.74	0.74	0.51	0.51	0.71 	0.00]; ...
            [0.74	1	    0.90	0.50	0.50	0.78	0.00]; ...
            [0.74	0.90	1	    0.50	0.50	0.78	0.00]; ...
            [0.51	0.50	0.50	1	    0.90	0.57	0.00]; ...
            [0.51	0.50	0.50	0.90	1	    0.57	0.00]; ...
            [0.71	0.78	0.78	0.57	0.57	1	    0.00]; ...
            [0.00	0.00	0.00	0.00	0.00	0.00	1]];

% settings:
pp = p4;
ers = pp.Ertn;
Evol = pp.Evol;
Ecorr = pp.Ecorr; clear pp;
longOnly = true;
weightSum = 0.07;
nAssets = size(Ecorr,2);
covar = Ecorr.*repmat(Evol,[1,nAssets]).*repmat(Evol',[nAssets,1]); 
param = []; % not used in 'InfoRatio'
periods = 12; % annual units
objFun =@(w)-InfoRatio(param,ers,covar,periods,w);

lb=zeros(nAssets,1);
ub=ones(nAssets,1)*weightSum;
%lb(4:5,1) = 0.015; 
ub=0.3*ones(nAssets,1)*weightSum; % no single asset can have more than 30% of total Risk Asset weight
%ub(1,1) = 0.00001; 
Aeq=ones(1,nAssets);
beq=weightSum*ones(1,1);
A = [];
b = [];
if longOnly == false
    lb = [];
    ub =[];
end

nonlcon = [];

w0 = ones(nAssets,1)/nAssets;
[w,fw,exitflag]=fmincon(objFun,w0,A,b,Aeq,beq,lb,ub,nonlcon); %#ok<ASGLU>
temp = [ers'*w; sqrt(w'*covar*w); (ers'*w/sqrt(w'*covar*w))];
disp('stats: E[rtn],E[vol],E[SR]')
disp(temp)
disp('weights')
disp(w)
if exitflag == -2
    uiwait(warndlg("No optimal portfolio been found under the constraints"));
end

end

function [c,ceq] = VarianceConstraint(w,covar,periods,riskLimit)
varp = (w'*covar*w)*(12/periods);

c=varp-riskLimit;
ceq=[];

end

function [c,ceq] = VaRConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit)
mup = (ers'*w)*(12/periods);
varp = (w'*covar*w)*(12/periods);
skewp = PortfolioSkewness(coskew,w)*(12/periods);
kurtp = PortfolioKurtosis(cokurt,w)*(12/periods)+3*(12/periods)*((12/periods)-1)*(w'*covar*w)^2;

c = ValueAtRisk(mup,sqrt(varp),skewp,kurtp,0.05)-riskLimit;
ceq=[];

end

function [c,ceq] = ESConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit)
mup = (ers'*w)*(12/periods);
varp = (w'*covar*w)*(12/periods);
skewp = PortfolioSkewness(coskew,w)*(12/periods);
kurtp = PortfolioKurtosis(cokurt,w)*(12/periods)+3*(12/periods)*((12/periods)-1)*(w'*covar*w)^2;

c = ExpectedShortfall(mup,sqrt(varp),skewp,kurtp,0.05)-riskLimit;
ceq = [];

end

function [c,ceq] = EMDDConstraint(w,ers,covar,periods,riskLimit)
mup = ers'*w;
varp = w'*covar*w;

c = ExpectedMaxDrawdown(mup,sqrt(varp),(12/periods))-riskLimit;
ceq = [];

end
