function[Z] = BetaFunction(index, X, method, PeriodReturn, PeriodBeta)
%
%--------------------------------------------------------------------------
%The function computes the beta based on returns
%
% INPUT:
    % Method
        % If method = 'linearfit' : Linerar regression
        % If method = 'robustfit' : Robustfit regression
    % index:          Benchmark to compute Beta
    % PeriodReturn:   Period over which returns are computed
    % perido_beta:    Period over which Beta is computed
% OUPUT
    % z = Beta
% Example
% X=c;index=c_mxwd;PeriodReturn=132;PeriodBeta=66;
%--------------------------------------------------------------------------
%
% Identify dimensions & Pre-locate
[nsteps,ncols] = size(X);
Z = zeros(size(X));
%  
% Compute returns
r_index=RateofChange(index,'rate of change',PeriodReturn); 
r_prices=RateofChange(X,'rate of change',PeriodReturn); 
%
for j=1:ncols
    % Detect the first value different from 0
    start_date=zeros(1,1);
    for k=1:nsteps
        if ~isnan(X(k,j)) && X(k,j)~=0 && ~isnan(index(k)) && index(k)~=0    
            start_date(1,1)=k;
            break
        end
    end
    % Compute beta
    for i=start_date(1,1)+PeriodReturn+PeriodBeta:nsteps
        % Explained Variable...............................................
        myyf=r_prices(i-PeriodBeta+1:i,j);           
        % Explaining Variables.............................................        
        xf=r_index(i-PeriodBeta+1:i);  
        switch method
            case 'linearfit'
                myctf=ones(PeriodBeta,1);  
                myxf=[myctf, xf];
            case 'robustfit'
                myxf=[xf];
        end
        % Models...........................................................     
        switch method
            case 'linearfit'
                % note: first Y - then X   
                b=regress(myyf,myxf); 
            case 'robustfit'
                % note: first X - then Y
                myxf=[xf];         
                b=robustfit(myxf,myyf);
        end
        % Allocate beta....................................................
        [rb,cb]=size(b);
        if rb>1, Z(i,j)=b(2,1); end
    end
end
