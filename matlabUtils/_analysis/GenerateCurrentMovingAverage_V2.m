function current_MA = GenerateCurrentMovingAverage_V2(security_data, MA_periods, MA_type)

% This function generates the current moving average of a security based on MA_periods and MA_type.
%
% Output: current_MA, is a number. 
%
% Inputs: security_data, a cell array of [date | data]
%	      MA_periods, is a number of moving average days
%		  MA_type, is a string
%
% MA_type: 'Simple', 'Exponential'

if nargin < 3 || isempty('MA_type'); MA_type = 'Simple'; end	% by default, MA_type is simple moving average

% if not enough data, just return zero
if size(security_data,1) < MA_periods
	disp('There is not enough Data to compute moving average.');
	current_MA = 0;
	return;
end

price = cell2mat(FillNaNDataWithEmptyCell(security_data(:,2)));	% use the last price

switch MA_type
case 'Simple'
	current_MA	= mean(price(end - MA_periods + 1 : end));	
case 'Exponential'
	mov_avg = tsmovavg(price', 'e', MA_periods);	
	current_MA = mov_avg(end);	
otherwise
	warning('Moving Average Type NOT Defined.');	
	current_MA = nan;
end

