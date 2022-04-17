function [YEq, YFct]= LinearForecast(Y, X, LookbackPeriod, LagX, LagForecast, OptionLog)
%
%__________________________________________________________________________
%
% This function computes the Equilibirum Value (EqY) and the Forecast
% Value (FctY) of a dependant variable Y based on a set or exogenous
% variables X (X is a matrix). 
%
% Method can be:
% 'RobustFixedPeriod'
% 'RobustRollingPeriod'
% 'LinearFixedPeriod'
% 'LinearRollingPeriod'
%
% OptionLog =0: Do not take the logarithm of Y
% OptionLog =1: Take the logarithm of Y
%
%
%__________________________________________________________________________

% Prelocate
YEq=zeros(size(Y));
YFct=zeros(size(Y));
%
% Lag Structure
[NstepsX,NcolsX]=size(X);
XLagged=zeros(size(X));
for j=1:NcolsX
    % PrelocateXvL
    XvL=zeros(NstepsX,1);
    % Lag Structure
    XvL(1+LagX(1,j):NstepsX,1)=X(1:NstepsX-LagX(1,j),j);
    % Allocate
    XLagged(:,j)=XvL(:,1);
end
%
% Search Max Lag: Allocate [] to ()
MLagX=zeros(1,NcolsX); for j=1:NcolsX, MLagX(1,j)=LagX(1,j); end
MaxLagX=max(MLagX);
%
% Identify starting date
for i=1:NstepsX
    if ~isnan(X(i,1)) && X(i,1)~=0
        StartDate=i;
    break
    end
end
%
% Time vector & Constant
CtV=ones(LookbackPeriod,1);  
TimeV=(1:1:LookbackPeriod)';

for i = StartDate + LookbackPeriod + MaxLagX + LagForecast: NstepsX
    % Extract X over LookbackPeriod
    XExtract= XLagged(i-LookbackPeriod+1-LagForecast:i-LagForecast,:); 
    XNow= XLagged(i,:); 
    % Vector of endogenous variables
        % For regression estimation
        XReg =[CtV, TimeV, XExtract];
        % For forecast
        XNowReg =[1, 1, XNow];
    % Exogeneous variabe
    YReg=Y(i-LookbackPeriod+1:i,1); 
    if OptionLog==1, YReg=log(dep_var);  end
    % Model
    beta=regress(YReg, XReg);  
    MatXReg=XReg(LookbackPeriod,:);
    % Equilibrium Value
    YEqN=MatXReg*beta;                
    if ~isnan(YEqN), YEq(i,1)=YEqN;  else, YEq(i,1)=YEq(i-1,1);   end
    % Forecast
    YFctN=XNowReg*beta;                
    if ~isnan(YFctN), YFct(i,1)=YFctN;  else, YFct(i,1)=YFct(i-1,1);   end    
    % Normalise return
    
end