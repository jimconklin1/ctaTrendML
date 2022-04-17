function YEq = EconometricModel(Y, X, LookbackPeriod)
%
%__________________________________________________________________________
%
% This function computes the Equilibirum Value (EqY) and the Forecast
% Value (FctY) of a dependant variable Y based on a set or exogenous
% variables X (X is a matrix). 
%
%__________________________________________________________________________

% Prelocate
YEq=zeros(size(Y));
NstepsY=length(Y);
%
% Time vector & Constant
CtV=ones(LookbackPeriod,1);  

for i = LookbackPeriod : NstepsY
    % Extract X over LookbackPeriod
    XExtract= X(i-LookbackPeriod+1:i,:); 
    % Vector of endogenous variables
        % For regression estimation
        XReg =[CtV,  XExtract];
        % For forecast
        %XNowReg =[1, 1, XNow];
    % Exogeneous variabe
    YReg=Y(i-LookbackPeriod+1:i,1); 
    % Model
    beta=regress(YReg, XReg);  
    MatXReg=XReg(LookbackPeriod,:);
    % Equilibrium Value
    YEqN=MatXReg*beta;                
    if ~isnan(YEqN), YEq(i,1)=YEqN;  else, YEq(i,1)=YEq(i-1,1);   end   
end