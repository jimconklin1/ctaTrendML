function [optimal_portfolio_weight, optimal_target] = estimateOptimizeTarget(portfolio_return, index_return, upper_bound, lower_bound, target)

% NOTE: This function generates the optimal weights of a portfolio that has the optimal value with the target index.
%
% NOTE: The output optimal_portfolio_weight is a column vector, optimal_target is a number.
%
% NOTE: The input portfolio_return is a matrix of returns, index_return is a column vector of index returns, upper_bound and lower_bound could be vectors or numbers.
%
% NOTE: target is a string indicating what value to optimize, 'Correlation', or 'TrackingError', or else.

if size(portfolio_return,1) ~= size(index_return)

	error('Sizes of portfolio and index returns DO NOT match.');
	
end


no_of_assets = size(portfolio_return,2);


if ~isempty(upper_bound)

	MaxWeight = ones(no_of_assets,1) .* upper_bound;
	
else

	MaxWeight = [];
	
end


if ~isempty(lower_bound)

	MinWeight = ones(no_of_assets,1) .* lower_bound;
	
else

	MinWeight = [];
	
end

options = optimoptions('fmincon','Algorithm','sqp','Display','off','TolFun',1e-8);


if strcmp(target, 'Correlation')

	[optimal_portfolio_weight, optimal_target] = fmincon(@(w) -PortCorrelation(w, portfolio_return, index_return), ones(no_of_assets,1)/no_of_assets, ...
	[], [], ones(1,no_of_assets), 1, MinWeight, MaxWeight, [], options);

	optimal_target = -optimal_target;
	
elseif strcmp(target, 'TrackingError')

	[optimal_portfolio_weight, optimal_target] = fmincon(@(w) PortTrackingError(w, portfolio_return, index_return), ones(no_of_assets,1)/no_of_assets, ...
	[], [], ones(1,no_of_assets), 1, MinWeight, MaxWeight, [], options);
	
else

	disp('Target is not defined. Use Correlation by default.');
	
	[optimal_portfolio_weight, optimal_target] = fmincon(@(w) -PortCorrelation(w, portfolio_return, index_return), ones(no_of_assets,1)/no_of_assets, ...
	[], [], ones(1,no_of_assets), 1, MinWeight, MaxWeight, [], options);

	optimal_target = -optimal_target;
	
end
	
	

% =================================================================================================

function objFunction = PortCorrelation(w, return_port, return_index)

% Here we just calculate the correlation between the weighted portfolio and the target index.

weighted_port_return = return_port * w;

correlation_matrix = corr([weighted_port_return, return_index]);

objFunction = correlation_matrix(1,2);



function objFunction = PortTrackingError(w, return_port, return_index)

% Here we just calculate the tracking error between the weighted portfolio and the target index.

weighted_port_return = return_port * w;

objFunction = sqrt(dot(weighted_port_return - return_index, weighted_port_return - return_index));







