function result = GenerateKNearestNeighbors_CrossDimension(data, target, k)

% This function generates the k nearest neighbors from data using target, based on correlation.
% It is an extension of the previous two versions. This version compares one-dimension target to multi-dimensional data, i.e., compare one asset to multiple assets.
%
% The ouput: result is a struct:
%					 1) no_of_nearest_neighbors, a number. sometimes this number is less than k.
%					 2) nearest_neighbors_data (length(target)x no_of_nearest_neighbors matrix), 
%					 3) nearest_neighbors_index (length(target)x (no_of_nearest_neighbors matrix*2)), here 2 columns for each nearest neighbors [data_no, data_index] 
%					 4) correlation_list (1 x no_of_nearest_neighbors matrix)
%
% The inputs: 1) data, a struct of data1, data2, data3 ..., all of which are column vectors
% 			  2) target, a column vectors
%			  3) k is a number, no of nearest neighbors
% 
% In this function, we set up a threshold of date distance where nearest neighbors shouldn't be very close to each other in terms of time.
%
% Currently, we set that threshold to be greater than the length of target.


no_of_data = length(fieldnames(data));

for i = 1 : no_of_data

	if length(data.(['data',num2str(i)])) < length(target) * k

		disp(['Data', num2str(i), ' Does Not Have Enough Data to Identify Nearest Neighbors.']);
		
		data = rmfield(data, ['data',num2str(i)]);
		
	end
	
end	

if isempty(fieldnames(data))

	error('No Data Left. Cannot Find Nearest Neighbors.');

end


m 					= length(target);

index_total 		= [];

data_total 			= [];

correlation_total 	= [];


% calculate all the correlations along all time series in data

for l = 1 : no_of_data

	if isfield(data, ['data',num2str(l)])
	
		data_l = data.(['data',num2str(l)]);

		data_l_length = length(data_l);

		for i = 1 : data_l_length - m + 1

			current_index 			= [l*ones(m,1),[i:i+m-1]'];	% first column being data number, second column being data index

			current_data 			= data_l(current_index(:,2));

			current_correlation 	= corr(current_data,target); 

			correlation_total	 	= [correlation_total, current_correlation];
			
			index_total 			= [index_total, current_index];
			
			data_total 				= [data_total, current_data];
			
		end		
	
	end
	
end


% rank all the correlation and remove the nan values

[sorted_correlation, sorted_correlation_idx] = sort(correlation_total, 'descend');

sorted_correlation_idx 	= sorted_correlation_idx(~isnan(sorted_correlation));

sorted_correlation 		= sorted_correlation(~isnan(sorted_correlation));


% if samples are very close to each other, remove that nearest neighbor

distance_threshold 		= length(target);

nearest_neighbors_data 	= data_total(:,sorted_correlation_idx(1));

nearest_neighbors_index = index_total(:,[sorted_correlation_idx(1)*2-1,sorted_correlation_idx(1)*2]);

correlation_list 		= sorted_correlation(1);

j = 2;

no_found = 1;

while no_found < k

	if j == length(sorted_correlation)
	
		disp(['Only found ',num2str(no_found),' nearest neighbors that are distant from each other.']);
		
		break;
		
	end
	
	potential_index = index_total(:,[sorted_correlation_idx(j)*2-1,sorted_correlation_idx(j)*2]);
	
	too_close = 0;
	
	for m = 1:size(nearest_neighbors_data,2)	% make sure the current sample is distant from all previous samples
	
		if potential_index(1,1) == nearest_neighbors_index(1,2*m-1) & abs(potential_index(1,2) - nearest_neighbors_index(1,2*m)) < distance_threshold
		
			too_close = 1;
			
			break;
			
		end
	
	end
	
	if ~too_close
	
		nearest_neighbors_data 	= [nearest_neighbors_data, data_total(:,sorted_correlation_idx(j))];
		
		nearest_neighbors_index = [nearest_neighbors_index, potential_index];
		
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

