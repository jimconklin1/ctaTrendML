function result = GenerateKNearestNeighbors_OneDimension(data, target, k)

% This function generates the k nearest neighbors from data using target, based on correlation.
%
% The ouput: result is a struct:
%					 1) no_of_nearest_neighbors, a number. sometimes this number is less than k.
%					 2) nearest_neighbors_data (length(target)x no_of_nearest_neighbors matrix), 
%					 3) nearest_neighbors_index (length(target)x no_of_nearest_neighbors matrix), 
%					 4) correlation_list (1 x no_of_nearest_neighbors matrix)
%
% The inputs: data and target are column vectors, k is a number.
% 
% In this function, we set up a threshold of date distance where nearest neighbors shouldn't be very close to each other in terms of time.
%
% Currently, we set that threshold to be greater than the length of target.

if length(data) < length(target) * k | length(target) == 1
	disp('Not Enough Data to Identify Nearest Neighbors.');
	result.no_of_nearest_neighbors 	= 0;
	result.nearest_neighbors_data 	= [];
	result.nearest_neighbors_index 	= [];
	result.correlation_list 		= [];
	return
elseif size(data,2) > 1 | size(target,2) > 1
	error('Cannot Handle Multi-Variable Data.');
end

m 			= length(target);
index_total = [];
data_total 	= [];

% calculate all the correlations along the time series
for i = 1 : length(data) - m + 1
	current_index 			= [i:i+m-1]';
	current_data 			= data(current_index);
	current_correlation 	= corr(current_data,target); 
	correlation_total(i) 	= current_correlation;
	index_total 			= [index_total, current_index];
	data_total 				= [data_total, current_data];
end

% rank all the correlation and remove the nan values
[sorted_correlation, sorted_correlation_idx] = sort(correlation_total, 'descend');
sorted_correlation_idx 	= sorted_correlation_idx(~isnan(sorted_correlation));
sorted_correlation 		= sorted_correlation(~isnan(sorted_correlation));

% if samples are very close to each other, remove that nearest neighbor
distance_threshold 		= length(target);
nearest_neighbors_data 	= data_total(:,sorted_correlation_idx(1));
nearest_neighbors_index = index_total(:,sorted_correlation_idx(1));
correlation_list 		= sorted_correlation(1);

j = 2;
no_found = 1;
while no_found < k
	if j == length(sorted_correlation)
		disp(['Only found ',num2str(no_found),' nearest neighbors that are distant from each other.']);
		break;
	end
	if ~any(abs(sorted_correlation_idx(j) - nearest_neighbors_index(1,:)) < distance_threshold)	% make sure the current sample is distant from all previous samples
		nearest_neighbors_data 	= [nearest_neighbors_data, data_total(:,sorted_correlation_idx(j))];	
		nearest_neighbors_index = [nearest_neighbors_index, index_total(:,sorted_correlation_idx(j))];	
		correlation_list 		= [correlation_list, sorted_correlation(j)];	
		no_found 				= no_found + 1;	
	end
	j = j + 1;		
end

% return the result
result.no_of_nearest_neighbors 	= no_found;
result.nearest_neighbors_data 	= nearest_neighbors_data;
result.nearest_neighbors_index 	= nearest_neighbors_index;
result.correlation_list 		= correlation_list;


