function [optimal_portfolio_weight, expected_return, expected_risk] = GenerateOptimalPortfolioWeight(portfolio, optimization_objective, target_return, target_risk)

% NOTE: This function returns the optimal portfolio weight of assets based on various optimization objectives.
%
% NOTE: The output optimal_portfolio_weight is a column vector of size Nx1 for N assets.
%
% NOTE: The input portfolio is an Portfolio object that has the information of AssetMean, AssetCovar, and Lower Bounds.
%
% NOTE: optimization_objective is a string indicating what type of optimization we want to achieve
%
%	'EqualValue'	- allocate equal notional to each asset, long only.
%	'EqualVol'		- preset a target vol for each asset, in this case target_risk is required.
%	'MaxReturn' 	- maximize return for whatever risk, in this case neither target_return or target_risk is required.
%	'MinRisk'		- minimize risk for whatever return, in this case neither target_return or target_risk is required.
%	'MaxSharpe'		- maximum Sharpe ratio, in this case neither target_return or target_risk is required.
%	'TargetReturn'	- minimize risk for a given return, in this case only target_return is required.
%	'TargetRisk'	- maximize return for a given risk, in this case only target_risk is required.
%	'RiskParity'	- within the portfolio, equalize the risk contribution from each asset
%
% NOTE: The inputs target_return and target_risk are numbers.

if ~strcmp(class(portfolio), 'Portfolio')

	disp('The input portfolio is NOT of Portfolio class. Cannot perform Portfolio Optimization.');
	
	optimal_portfolio_weight = []; expected_return = []; expected_risk = [];
	
	return;

end

disp('======================= Portfolio Optimization starts. ========================');

switch lower(optimization_objective)

	case 'equalvalue'
	
		disp('Objective is to Equalize Notional Value.');
		
		optimal_portfolio_weight = 1 / portfolio.NumAssets * ones(portfolio.NumAssets,1);
		
	case 'equalvol'
	
		disp('Objective is to Preset Target Vol.');
		
		optimal_portfolio_weight = 1 / portfolio.NumAssets * target_risk ./ sqrt(diag(portfolio.AssetCovar));
		
		optimal_portfolio_weight(~isfinite(optimal_portfolio_weight)) = 1 / portfolio.NumAssets;
		
	case 'maxreturn'
	
		disp('Objective is to Maximize Return and NOT care about Risk.');
	
		optimal_portfolio_weight = estimateFrontierLimits(portfolio, 'Max');
	
	case 'minrisk'
	
		disp('Objective is to Minimize Risk and NOT care about Return.');
		
		optimal_portfolio_weight = estimateFrontierLimits(portfolio, 'Min');
		
	case 'maxsharpe'
	
		disp('Objective is to Maximize Sharpe Ratio.');
	
		optimal_portfolio_weight = estimateMaxSharpeRatio(portfolio);
		
	case 'targetreturn'
	
		if exist('target_return') & ~isempty(target_return) & strcmp(class(target_return),'double')
		
			disp('Objective is to Achieve Target Return.');
	
			optimal_portfolio_weight = estimateFrontierByReturn(portfolio, target_return);
			
		else
		
			disp('Target Return is NOT specified. Cannot perform Portfolio Optimization.');
			
			optimal_portfolio_weight = [];
		
		end
	
	case 'targetrisk'
	
		if exist('target_risk') & ~isempty(target_risk) & strcmp(class(target_risk),'double')
		
			disp('Objective is to Achieve Target Risk.');
	
			optimal_portfolio_weight = estimateFrontierByRisk(portfolio, target_risk);
			
		else
		
			disp('Target Risk is NOT specified. Cannot perform Portfolio Optimization');
			
			optimal_portfolio_weight = [];
			
		end
		
	case 'riskparity'
	
		disp('Objective is to Equalize Risk (Risk Parity).');
	
		optimal_portfolio_weight = estimateRiskParity(portfolio);

	otherwise

		disp('Objective is NOT specified. Cannot Perform Portfolio Optimization.');
		
		optimal_portfolio_weight = [];

end

if ~isempty(optimal_portfolio_weight)

	[expected_risk, expected_return] = estimatePortMoments(portfolio, optimal_portfolio_weight);
	
	disp('===================== Portfolio Optimization is finished. =====================');
	
	disp(['  Expected Return: ', num2str(expected_return * 100),'%','   Expected Risk: ', num2str(expected_risk * 100),'%','   Sharpe Ratio: ', num2str(expected_return / expected_risk * sqrt(252))]);
	
	disp('===============================================================================');

else

	expected_return = []; expected_risk = [];

end
