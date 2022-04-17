function innovStruct = runInnovationDecomposition(dataStruct,dataStruct2)

% bonds:    dP/P = theta*dt + (DP/Dtheta)*dTheta + (DP/Dpi)*dPi + (DP/Dr)*dR + epsilon_p(t)
%           P    = sum_i=1:N_{ (cf(t+i) / (1 + r)*(1 + pi)*(1 + theta)))^i}* earn
% equities: dQ/Q = xi*dt + (DQ/Dxi)*dXi + theta*dt + (DQ/Dtheta)*dTheta + (DQ/Dg)*dG + (DP/Dr*)*dR + epsilon_q(t)
%           Q    = sum_i=1:inf_{ ( ((1+pi)*(1+g)) / (1 + r)*(1 + pi)*(1 + theta)*(1 + xi) )^i }
%           i    = (1+r)*(1+pi)*(1+theta) - 1
% dynamics: pi(t+1) = dPi(t+1) + pi(t)
%           r(t+1) = dR(t+1) + r(t)
%           theta(t+1) = dTheta(t+1) + theta(t)
%           g(t+1) = dG(t+1) + g(t)
%           xi(t+1) = dXi(t+1) + xi(t)
% state-space variables:
%           
% first do US:
i1 = find(strcmp(dataStruct2.header,'USSWIT7 CMPL Curncy'),1,'first');
i2 = find(strcmp(dataStruct2.header,'USSW10 CMPL Curncy'),1,'first');
i3 = find(strcmp(dataStruct2.header,'SPX Index PE'),1,'first');
pi = dataStruct2.levels(:,i1); 
dPi = [0; (pi(2:end,:)-pi(1:end-1,:))]; 
i = dataStruct2.levels(:,i2)/100; 
cf = calcEWA(i,20); % have your coupon rate be a smoothed ytm yield
i1 = find(strcmp(dataStruct.header,'TY1 Comdty'),1,'first'); 
i2 = find(strcmp(dataStruct.header,'ES1 Index'),1,'first'); 
P = 100*calcCum(dataStruct.close(:,i1),1); 
dPoP = dataStruct.close(:,i1); 
dPoP(isnan(dPoP)) = 0; 
Q = 100*calcCum(dataStruct.close(:,i2),1); 
dQoQ = dataStruct.close(:,i2); 
earn =  dataStruct.close(:,i3); 
earn = 1./earn; 
indx = isinf(earn) | earn<0; 
earn(indx) = 0; 

innovStruct.dates = dataStruct.dates;
innovStruct.us.pi = pi;
innovStruct.us.dPi = dPi;
innovStruct.us.i = i;
innovStruct.us.cf = cf;
innovStruct.us.P = P;
innovStruct.us.dPoP = dPoP;
innovStruct.us.Q = Q;
innovStruct.us.dQoQ = dQoQ;
innovStruct.us.earn = earn;
end % function

function y = dBondPartial(c,T,pi,r,tPrem,dx)
dn = 1-dx;
up = 1+dx;
DF = bondDF(pi,r,tPrem);
px = bondPx(DF,T,c);
pxDnPi = bondPx(bondDF(pi*dn,r,tPrem),T,c);
pxUpPi = bondPx(bondDF(pi*up,r,tPrem),T,c);
yPi = (pxUpPi - pxDnPi)./px; 
pxDnR = bondPx(bondDF(pi,r*dn,tPrem),T,c);
pxUpR = bondPx(bondDF(pi,r*up,tPrem),T,c);
yR = (pxUpR - pxDnR)./px; 
pxDnTprm = bondPx(bondDF(pi,r,tPrem*dn),T,c);
pxUpTprm = bondPx(bondDF(pi,r,tPrem*up),T,c);
yTprm = (pxUpTprm - pxDnTprm)./px; 
y = [yPi,yR,yTprm];
end

function y = dEqPartial(e,pi,r,g,tPrem,erPrem,dx)
dn = 1-dx;
up = 1+dx;
DF = eqDF(pi,r,g,tPrem);
px = eqPx(DF,e);
pxDnPi = eqPx(eqDF(pi*dn,r,g,tPrem,erPrem),e);
pxUpPi = eqPx(eqDF(pi*up,r,g,tPrem,erPrem),e);
yPi = (pxUpPi - pxDnPi)./px; 
pxDnR = eqPx(eqDF(pi,r*dn,g,tPrem,erPrem),e);
pxUpR = eqPx(eqDF(pi,r*up,g,tPrem,erPrem),e);
yR = (pxUpR - pxDnR)./px; 
pxDnG = eqPx(eqDF(pi,r,g*dn,tPrem,erPrem),e);
pxUpG = eqPx(eqDF(pi,r,g*up,tPrem,erPrem),e);
yG = (pxUpG - pxDnG)./px; 
pxDnTprm = eqPx(eqDF(pi,r,g,tPrem*dn,erPrem),e);
pxUpTprm = eqPx(eqDF(pi,r,g,tPrem*up,erPrem),e);
yTprm = (pxUpTprm - pxDnTprm)./px; 
pxDnErprm = eqPx(eqDF(pi,r,g,tPrem,erPrem*dn),e);
pxUpErprm = eqPx(eqDF(pi,r,g,tPrem,erPrem*up),e);
yErprm = (pxUpErprm - pxDnErprm)./px; 
y = [yPi,yR,yG,yTprm,yErprm];
end

function y = bondPx(DF,T,c)
% inputs: 
%  DF = discount factor, of size 1 x num of periods
%  T = bond maturity, 1 x 1, assumes same maturity bond in price series,
%      units in # of periods (default: yrs)
%  c = bond coupon, of size 1 x num of periods
TT = length(DF);
npvC = zeros(TT,1);
for t = 1:T-1
   npvC = npvC + (DF.^t).*c;
end % for
npvC = npvC*100;
npvP = 100*(DF.^T); 
y = npvC + npvP;
end % fn

function y = eqPx(DF,e)
% inputs: 
%  DF = discount factor, of size 1 x num of periods
%  e = earnings yield, of size 1 x num of periods
y = e./(1 - DF);
end % fn

function y = bondDF(pi,r,tPrem)
y = 1./((1+pi).*(1+r).*(1+tPrem));
end % function

function y = eqDF(pi,r,g,tPrem,erPrem)
y = ((1+pi).*(1+g))./((1+pi).*(1+r).*(1+tPrem).*(1+erPrem));
end % function

