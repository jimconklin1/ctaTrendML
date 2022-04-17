function y = AdjustedPercentile3(x, MinimumDivider)
%__________________________________________________________________________
%
% Add a minimum value to percentile as it gives 0
% rationale: the percentile function assigns value from 0...to 100
%            when for instance this percentile is used as a weighting
%            device, so that w(i) = Percentile(i) / Sum_i[Percentile(i)]
%            the asset with Percentile(i) = 0, will hae a weight of 0,
%            which can be problematic
%            Add a result, the algorihm take the smallest non-zero
%            percentile, divide it by the the variable "MinimumDivider" and
%            assigns this value to Percentile(i) = 0.
%            Therefore Percerntile(i)=0 ...> Percerntile(i)=MinimumDivider
%            Then, in order to get Sum([w(i)] = 100, the algorithm 
%            redistributes -MinimumDivider / (Nb -1) oit over the other
%            individuals (assets).
%__________________________________________________________________________


    % Dimensions
    ncols = size(x,2);
    y = zeros(1,ncols);

    Index0 = find(x==0); % Find column index where Percentile is 0
    
    if size(Index0,1) == 1 %&& size(Index0,2) == 1
    
        xWithout0 = x(find(x~=0)); % Construct a row vector of percentile ranks different from 0
        minEx0 = min(xWithout0);   % Compute the minimum of this row vector
        clear xWithout0

        MinValFor0 = minEx0 / MinimumDivider; % Set the new value for Percentile 0 
        y(1,Index0) = MinValFor0;

        % Re-adjust for the other
        for u = 1:ncols
            if u ~= Index0, 
                y(1,u)=x(1,u) - MinValFor0/(ncols-1);
            end
        end
        
    else
         y = x;%repmat(1/ncols, 1, ncols);
    end