function[Y] = RollingPolynom(X,PolynomOrder)
%__________________________________________________________________________
%
%
%__________________________________________________________________________
%
[nsteps,ncols]=size(X);
Y=zeros(size(X));
%
%
for j=1:ncols
    % Detect Starting Date
    % Step 1: Find the first cell to start the code
    StartDate=zeros(1,1);
    for i=1:nsteps
        if ~isnan(X(i,j)), StartDate(1,1)=i;
        break
        end
    end    
    % Impose Preformation
    PreformationPeriod=10;
    % Step 2
    for i=StartDate(1,1):nsteps
        % Time
        tdate = (1:1:i-StartDate(1,1)+1)'; 
        % Compute Polynom Coefficients
        p_coeffs = polyfit(tdate,X(StartDate(1,1):i,j),PolynomOrder);
        % Compute Adjustment
        tfit=tdate;
        yfit = polyval(p_coeffs,tfit); 
        % Assign
        Y(i,j)=yfit(length(yfit),1);
    end
end
%    
%plot(tfit,yfit,'r-','LineWidth',2)
%legend('Data','Polynomial Fit','Location','NW')