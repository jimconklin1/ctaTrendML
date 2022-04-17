%
%
% Defining Portfolio Problem
%
nbStrats = 6;
Asset = { 's1', 's2', 's3', 's4', 's5', 's6'};
Price = ones(nbStrats,1);
Holding = 1/nbStrats * ones(nbStrats,1);
UnitCost = zeros(nbStrats,1);

Blotter = dataset({Price, 'Price'}, {Holding, 'InitHolding'},'obsnames',Asset);
Wealth = sum(Blotter.Price .* Blotter.InitHolding);
Blotter.InitPort = (1/Wealth)*(Blotter.Price .* Blotter.InitHolding);
Blotter.UnitCost = UnitCost;

% Simulating Asset Price

% Mean Return
AssetMean= mean(jo)';%zeros(nbStrats,1);

% Covariance Matrix with Shrinkage estimator
[sigma,shrinkage] = covMarket(jo,0);

AssetCovar = sigma;

% Simulating Asset Prices

X = portsim(AssetMean'*12, AssetCovar*12, 60);
[Y, T] = ret2tick(X, [], 1/12);                

% Setting Up the Portfolio Object

p = Portfolio('Name', 'Asset Allocation Portfolio', ...
'AssetList', Asset, 'InitPort', Blotter.InitPort);

p = p.setDefaultConstraints;
p = p.setGroups([ 1, 1, 1, 1, 1, 1 ], 0.5,  1);
%p = p.addGroups([ 1, 1, 1, 1, 1, 1 ], [0, 0, 0 , 0, 0, 0],  [1, 1, 1 , 1, 1, 0.5]);

p = p.setAssetMoments(AssetMean/12, AssetCovar/12);

p = p.estimateAssetMoments(Y, 'DataFormat', 'Prices');

p.AssetMean = 12*p.AssetMean;
p.AssetCovar = 12*p.AssetCovar;

display(p);

[lb, ub] = p.estimateBounds;
display([lb, ub]);

% Plotting the Efficient Frontier

p.plotFrontier(40);

% Evaluating Gross vs. Net Portfolio Returns

q = p.setCosts(UnitCost, UnitCost);
display(q);

%Analyzing Descriptive Properties of the Portfolio Structures

[prsk0, pret0] = p.estimatePortMoments(p.InitPort);

pret = p.estimatePortReturn(p.estimateFrontierLimits);
qret = q.estimatePortReturn(q.estimateFrontierLimits);

fprintf('Annualized Portfolio Returns ...\n');
fprintf('                                   %6s    %6s\n','Gross','Net');
fprintf('Initial Portfolio Return           %6.2f %%  %6.2f %%\n',100*pret0,100*pret0);
fprintf('Minimum Efficient Portfolio Return %6.2f %%  %6.2f %%\n',100*pret(1),100*qret(1));
fprintf('Maximum Efficient Portfolio Return %6.2f %%  %6.2f %%\n',100*pret(2),100*qret(2));

% Obtaining a Portfolio at the Specified Return Level on the Efficient Frontier

Level = 0.3;

qret = q.estimatePortReturn(q.estimateFrontierLimits);
qwgt = q.estimateFrontierByReturn(interp1([0, 1], qret, Level));
[qrsk, qret] = q.estimatePortMoments(qwgt);

fprintf('Portfolio at %g%% return level on efficient frontier ...\n',100*Level);
fprintf('%10s %10s\n','Return','Risk');
fprintf('%10.2f %10.2f\n',100*qret,100*qrsk);

display(qwgt);

display(q.estimatePortRisk(qwgt));

% Obtaining a Portfolio at the Specified Risk Levels on the Efficient Frontier

TargetRisk = [ 0.10; 0.15; 0.20 ];
qwgt = q.estimateFrontierByRisk(TargetRisk);
display(qwgt);

display(q.estimatePortRisk(qwgt));
[qwgt, qbuy, qsell] = q.estimateFrontierByRisk(0.15);
disp(sum(qbuy + qsell)/2)

q = q.setTurnover(0.15);
[qwgt, qbuy, qsell] = q.estimateFrontierByRisk(0.15);

qbuy(abs(qbuy) < 1.0e-5) = 0;
qsell(abs(qsell) < 1.0e-5) = 0;  % zero out near 0 trade weights

Blotter.Port = qwgt;
Blotter.Buy = qbuy;
Blotter.Sell = qsell;

display(Blotter);

TotalCost = Wealth * sum(Blotter.UnitCost .* (Blotter.Buy + Blotter.Sell));
Blotter.Holding = Wealth * (Blotter.Port ./ Blotter.Price);
Blotter.BuyShare = Wealth * (Blotter.Buy ./ Blotter.Price);
Blotter.SellShare = Wealth * (Blotter.Sell ./ Blotter.Price);
Blotter.Buy = [];
Blotter.Sell = [];
Blotter.UnitCost = [];

%Displaying the Final Results
display(Blotter);

q.plotFrontier(40);
hold on
scatter(q.estimatePortRisk(qwgt), q.estimatePortReturn(qwgt), 'filled', 'r');
h = legend('Initial Portfolio', 'Efficient Frontier', 'Final Portfolio', 'location', 'best');
set(h, 'Fontsize', 8);
hold off









