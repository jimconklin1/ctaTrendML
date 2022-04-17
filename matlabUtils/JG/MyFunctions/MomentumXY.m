function[Z] = MomentumXY(X,Y,LagX,LagY,method)
%__________________________________________________________________________
%The function computes the ratio between X & Y
% 2 methods are possible
% - Ratio
% - Difference
% We can also lag the time serries
%__________________________________________________________________________
%
% Dimension & Pre-locate matrix
[NbSteps,NbCols]=size(X);
Z=zeros(size(X));
%
% Lag the function if needed
Xl=zeros(size(X));
Yl=zeros(size(Y));
Xl(LagX+1:NbSteps,:)=X(1:NbSteps-LagX,:);
Yl(LagY+1:NbSteps,:)=Y(1:NbSteps-LagY,:);
% Identify max lag
MaxLag=max(LagX,LagY);
switch method
    case 'ratio'
        for i=MaxLag+2:NbSteps
            for j=1:NbCols
                if ~isnan(Xl(i,j)) && ~isnan(Yl(i,j)) 
                    if Yl(i,j)~=0
                        Z(i,j)=Xl(i,j)/Yl(i,j)-1;
                    else
                        Z(i,j)=Z(i-1,j);
                    end
                else
                    Z(i,j)=Z(i-1,j);
                end
            end
        end
    case 'difference'
        Z=Xl-Yl;
        clear Xl Yl
end