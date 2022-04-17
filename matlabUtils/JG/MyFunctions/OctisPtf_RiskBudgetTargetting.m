%
%__________________________________________________________________________
%
%
% -- Estimate Clean Correlation Matrix --
ptfreturns = jo;
[stdYX , corYX] = EstimateUnitNormalCorr(ptfreturns, 30, 0.1);

% -- Risk Budget Target --
risk_target = 10 / 100;

% -- Find Allocation --
%allocation = zeros(size(stdYX));
%[~,nstrats] = size(allocation);
vones = ones(size(stdYX));

[sigma,shrinkage] = covMarket(jo,0);
StratCovar = 12 * sigma;
StratMean = 12 * mean(jo);
StratStd = sqrt(diag(StratCovar));

ptf = Portfolio;
ptf = ptf.setAssetMoments(StratMean, StratCovar);
ptf = ptf.setDefaultConstraints;
pwgt = ptf.estimateFrontierByRisk([0.8, 0.10, 0.12]);

[prsk0, pret0];

% determine the bounds for the portfolio se

N = risk_target / power(stdx' * inv(sigma) * stdx, 0.5) * inv(sigma) * stdx;



for j=1:nstrats
    allocation(1,j) = risk_target / (vones * inv(corYX) * vones')^0.5 *  (inv(corYX) * vones' / stdYX(1,j));
end