function y = ExtractJohansenPair(method,LikelihoodTrace, ...
    MaxEigenValue,CriticalTrace,CriticalEigenValue)
%__________________________________________________________________________
%
% This Function allows to identify a pair based on the Johansen methodology
%
% The "johansen.m" function needs to be run beforehand
%
% Two methodologies are allowed:
%
%--------------------------------------------------------------------------
% INPUT
%
% - Methodology 1: Likelihood Ratio Trace Statistics
%   IF the (observed) likelihood ratio trace statistics is greater than the
%   (theoretical) critical value THEN we rejects the null hypothesis r<=p
%
% - Methodology 2: Maximum Eigenvalue Statistics
%   IF the (observed) maximum eigenvalue statistics is greater than the
%   (theoretical) critical value THEN we rejects the null hypothesis r<=p
%
%--------------------------------------------------------------------------
% OUTPUT
%
% output is y
% - 1st column is the critical value @ 90%
% - 2nd column is the critical value @ 95%
% - 3rd column is the critical value @ 99%
%
%--------------------------------------------------------------------------
% Note: "johansen.m" function has a structure as output.
% If you need to retrieve this output for further computation, u may need 
% to assign this structure to the following variables:
% Observed_LikelihoodTrace      = result.lr1;
% Observed_MaxEigenValue        = result.lr2;
% Theoretical_CriticalTrace     = result.cvt;
% Theoretica_CriticalEigenValue = result.cvm;
%
%__________________________________________________________________________
%
% Prelocate Matrix
y=zeros(1,3);
switch method
    case 'trace'
        if LikelihoodTrace(1,1)>CriticalTrace(1,1) || LikelihoodTrace(2,1)>CriticalTrace(2,1) 
            y(1,1)=1;
        else
            y(1,1)=0;
        end
        if LikelihoodTrace(1,1)>CriticalTrace(1,2) || LikelihoodTrace(2,1)>CriticalTrace(2,2)
            y(1,2)=1;
        else
            y(1,2)=0;
        end
        if LikelihoodTrace(1,1)>CriticalTrace(1,3) || LikelihoodTrace(2,1)>CriticalTrace(2,3)
            y(1,3)=1;
        else
            y(1,3)=0;
        end        
    case 'eigenvalue'
       if MaxEigenValue(1,1)>CriticalEigenValue(1,1) || MaxEigenValue(2,1)>CriticalEigenValue(2,1)
            y(1,1)=1;
        else
            y(1,1)=0;
        end
        if MaxEigenValue(1,1)>CriticalEigenValue(1,2) || MaxEigenValue(2,1)>CriticalEigenValue(2,2)
            y(1,2)=1;
        else
            y(1,2)=0;
        end
        if MaxEigenValue(1,1)>CriticalEigenValue(1,3) || MaxEigenValue(2,1)>CriticalEigenValue(2,3)
            y(1,3)=1;
        else
            y(1,3)=0;
        end                      
end