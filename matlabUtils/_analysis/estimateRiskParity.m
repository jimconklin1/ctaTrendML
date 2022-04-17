function pwgt = estimateRiskParity(obj)

% NOTE: This function implements a Risk Parity Optimization.
%
% NOTE: The output is the portfolio weights column vector. Input is the portfolio object.

N = obj.NumAssets;

if ~isempty(obj.LowerBound)

	MinMarginalWeight = obj.LowerBound;
	
else

	MinMarginalWeight = zeros(N,1);

end

if ~isempty(obj.UpperBound)

	MaxMarginalWeight = obj.UpperBound;
	
else

	MaxMarginalWeight = ones(N,1);

end


Sigma = obj.AssetCovar;

options = optimoptions('fmincon','Algorithm','sqp','Display','off','TolFun',1e-8);

pwgt = fmincon(@(w) PortRiskParity(w, Sigma, N), ones(N,1)/N, ...
				[], [], ones(1,N), 1, MinMarginalWeight, MaxMarginalWeight, [], options);
								
total_risk  = sqrt(pwgt'*obj.AssetCovar*pwgt);

each_risk  	= pwgt .* ( obj.AssetCovar*pwgt/sqrt(pwgt'*obj.AssetCovar*pwgt) );

Risk_Distribution = each_risk / total_risk				
				
										
	
% =================================================================================================
	
function objFunction = PortRiskParity(w, Sigma, N)

% *************************************************************************************************

% The below optimization problem doesn't seem to work, giving inconsistent results, with negative weights. 
% See JPMorgan's "Systematic Strategies Across Asset Classes"

%portvar = w' * Sigma * w;
%
%portbeta = Sigma * w ./ portvar;
%
%fval = 0;
%
%for i = 1:N
%
%	fval = fval + (w(i) * portbeta(i) - 1 / N) ^ 2;
%
%end
%
%objFunction = fval;

% *************************************************************************************************



% *************************************************************************************************

% The below optimization problem seems like the most common one. 
% See "Efficient Algorithms for Computing Risk Parity Portfolio Weights".

TRC = w .* (Sigma * w); 
  
objFunction = 0; 
  
for i = 1:N

	for j = i+1:N
	
		diff_ij = TRC(i) - TRC(j) ; 
		
		objFunction = objFunction + diff_ij * diff_ij ; 
		
    end 
	
end

objFunction = sqrt(objFunction) ;
 
% *************************************************************************************************




 
 
