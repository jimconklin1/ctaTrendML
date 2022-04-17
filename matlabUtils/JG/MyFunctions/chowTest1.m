function [Fobs, Ftheo] =chowTest1(x, LagReturn, BreakPoint, NbParameters, alpha)
%__________________________________________________________________________
%
% Computes the Chow test
% Chow test works if one knows whether and WHEN there is a break point
% Chow test follows F-distribution F(k,n-2k)
% Input:
% x = matrix of price
% BreakPointx = location of the breakpoint
% NbParameters = # of parameters to bes estimated (for a simple "slope"
%                model such as y = a*t+b, NbParameters =2 for e.g.
% alpha = critical value for an F distribution (load the corresponding
%         table)
%
% Decision rule:
% The null hypothesis in this case is structural stability, if we reject 
% the null hypothesis, it means we have a structural break in the data
% if F_observed > F_theo, ...
%                  reject the null hypothesis of structural stability
% Caveat: Chow test often rejects structural stability at each and every
% point.
%NbParameters=3;alpha=0.1;BreakPoint=2061;
%__________________________________________________________________________

% -- load Fisher table according to critical value  --
if alpha==0.1
    load('S:\Research\quantStrategy\JG_MatlabFunctions\MyFunctions\ftable010.mat')
    ftable=ftable010;
elseif alpha==0.05
    load('S:\Research\quantStrategy\JG_MatlabFunctions\MyFunctions\ftable005.mat')  
    ftable=ftable005;
elseif alpha==0.025
    load('S:\Research\quantStrategy\JG_MatlabFunctions\MyFunctions\ftable0025.mat')    
    ftable=ftable0025;
elseif alpha==0.01
    load('S:\Research\quantStrategy\JG_MatlabFunctions\MyFunctions\ftable001.mat')   
    ftable=ftable001;
end

[nsteps,ncols] = size(x);

x = Delta(x,'roc',LagReturn);   % Compute returns
xsnap = x(:,2:ncols);           % Extract exogenuous variables
ysnap = x(:,1);                 % Extract endogenuous variable

% Find the first non zero 
start_date=zeros(1,1);
for i=1:nsteps
    if ~isnan(ysnap(i)) && ysnap(i)~=0
        start_date(1,1)=i;
    break               
    end                                 
end

% Run Regression for all data
y = ysnap(start_date(1,1) : nsteps,1);
x = xsnap(start_date(1,1) : nsteps,1:3);
%period = nsteps-start_date(1,1)+1;
%xtime = zeros(period ,1); for i=1:period,xtime(i)=i;end;
[b,bint,r] = regress(y,x);
Sum_rTot = sum(r .* r);
    
% Run regression for first period
y = ysnap(start_date(1,1) : BreakPoint,1);
x = xsnap(start_date(1,1) : BreakPoint,1:3);
%period = BreakPoint - start_date(1,1)+1;
%xtime = zeros(period ,1); for i=1:period,xtime(i)=i;end;
[b,bint,r] = regress(y,x);
Sum_rPer1 = sum(r .* r);    
    
% Run regression for second period
y = ysnap(BreakPoint : nsteps,1);
x = xsnap(BreakPoint : nsteps,1:3);
%period = nsteps - BreakPoint+1;
%xtime = zeros(period ,1); for i=1:period,xtime(i)=i;end;
[b,bint,r] = regress(y,x);
Sum_rPer2 = sum(r .* r);    
    
% Compute observed F
n=nsteps-start_date(1,1)+1;
Fobs = (Sum_rTot - (Sum_rPer1 + Sum_rPer2)/NbParameters) / ((Sum_rPer1 + Sum_rPer2)/(n-2*NbParameters));

% Fetch theoretical F: F(k,n-2k) 
% with k=NbParameters in column and n-2*NbParameters in row
if NbParameters <= 10
    colPosition = NbParameters;
elseif NbParameters == 11 || NbParameters == 12 
    colPosition = 11;
elseif NbParameters > 12 && NbParameters <= 15  
    colPosition = 12;
end

if n-2*NbParameters <= 30
    rowPosition = n-2*NbParameters;
elseif n-2*NbParameters >= 31 && n-2*NbParameters < 40
    rowPosition  = 31;     
elseif n-2*NbParameters > 40 && n-2*NbParameters <= 60
    rowPosition  = 32;  
elseif n-2*NbParameters > 60 && n-2*NbParameters <= 120
    rowPosition  = 33;  
elseif n-2*NbParameters > 120
    rowPosition  = 34;          
end

Ftheo = ftable(rowPosition,colPosition);
    
    
    
