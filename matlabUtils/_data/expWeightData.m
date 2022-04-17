function [X] = expWeightData(X,HL)
gamma = 0.5^(1/HL);
temp = gamma.^((length(X)-1):-1:0)';
xCoeffs = repmat(temp,[1,size(X,2)]);
X = X.*xCoeffs;
end % fn 