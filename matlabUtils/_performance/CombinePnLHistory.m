function pnl_history_combined = CombinePnLHistory(pnl_history, combine_period)

% NOTE: This function combines pnl history into days, months, or years, based on combine_period.
%
% NOTE: The output is a cell array that has the format [date | data].
%
% NOTE: The input pnl_history is a cell array with the format [date | data]. combine_period is a string indicating day, month, or year.

pnl_history_combined = cell(0);

if cellfun('isempty', pnl_history)

	disp('No Daily PnL History!');

	return;

end

if strcmp(combine_period,'year')

	k = 1;
	
	current_start_index = 1;
	
	for i = 2 : size(pnl_history,1)

		datevec_current = datevec(pnl_history(i,1));
		
		datevec_previous = datevec(pnl_history(i-1,1));
		
		if datevec_current(1) ~= datevec_previous(1)
		
			if i ~= size(pnl_history,1)
		
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
				
				current_start_index = i;
				
				k = k + 1;
				
			else
			
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
				
				pnl_history_combined(k+1,:) = [datestr(pnl_history(end,1),'yyyy') num2cell(sum(cell2mat(pnl_history(end,2))))];
				
			end
			
		elseif i == size(pnl_history,1)
		
			pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:end,2))))];
		
		end
	
	end

elseif strcmp(combine_period,'month')

	k = 1;
	
	current_start_index = 1;
	
	for i = 2 : size(pnl_history,1)

		datevec_current = datevec(pnl_history(i,1));
		
		datevec_previous = datevec(pnl_history(i-1,1));
		
		if datevec_current(1) ~= datevec_previous(1) || datevec_current(2) ~= datevec_previous(2)
		
			if i ~= size(pnl_history,1)
		
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy.mm') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
				
				current_start_index = i;
				
				k = k + 1;
			
			else
		
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy.mm') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
				
				pnl_history_combined(k+1,:) = [datestr(pnl_history(end,1),'yyyy.mm') num2cell(sum(cell2mat(pnl_history(end,2))))];
				
			end
			
		elseif i == size(pnl_history,1)
		
			pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'yyyy.mm') num2cell(sum(cell2mat(pnl_history(current_start_index:end,2))))];
		
		end
	
	end

elseif strcmp(combine_period,'day')

	k = 1;
	
	current_start_index = 1;
	
	for i = 2 : size(pnl_history,1)

		datevec_current = datevec(pnl_history(i,1));
		
		datevec_previous = datevec(pnl_history(i-1,1));
		
		if datevec_current(1) ~= datevec_previous(1) || datevec_current(2) ~= datevec_previous(2) || datevec_current(3) ~= datevec_previous(3)
		
			if i ~= size(pnl_history,1)
		
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'dd-mmm-yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
			
				current_start_index = i;
			
				k = k + 1;
				
			else
			
				pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'dd-mmm-yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:i-1,2))))];
				
				pnl_history_combined(k+1,:) = [datestr(pnl_history(end,1),'dd-mmm-yyyy') num2cell(sum(cell2mat(pnl_history(end,2))))];
			
			end
			
		elseif i == size(pnl_history,1)
		
			pnl_history_combined(k,:) = [datestr(pnl_history(current_start_index,1),'dd-mmm-yyyy') num2cell(sum(cell2mat(pnl_history(current_start_index:end,2))))];
		
		end
	
	end

end


