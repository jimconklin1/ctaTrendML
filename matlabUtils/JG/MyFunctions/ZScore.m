function z = ZScore(x,method,period,MinMax,DescendAscend)

%__________________________________________________________________________
%
% This function computes the z-score and applies Upper and Lower bounds
% (MinMax with MinMax(1,1)=Lower Bound & MinMax(1,2)=Upper Bound) to the
% Z-Score.
% It computes the Z-Score either with the arithmetic or with the
% exponential moving averages.
%
% INPUT--------------------------------------------------------------------
% x         =   matrix of raw data
% 'method'  =   - 'zscore arithmetic'  : the arithmetic moving average is used
%               - 'zscore exponential' :  the exponential moving average is used
%               - 'normalisation'      : does not center, only divided by
%               standard deviation.
% period    =   the period over which the rolling average and standard
%               deviations are computed.
% minmax    =   minmax(1,1) = the lower bound (for e.g., -3)
%               minmax(1,2) = the upper bound (for e.g., 3)
% DescendAscend = DescendAscend = 1  ....> Descend
%                 DescendAscend = -1 ....> Ascend
%                 z .* DescendAscend
% note: typically, used DescendAscend=1
%
% OUTPUT-------------------------------------------------------------------
% z         =   z is the z-score.
% Typical form: z = ZScore(x,'arithmetic',20,[-3,3],1)
%__________________________________________________________________________

% Identify Dimensions & Prelocate matrix
[nsteps,ncols] = size(x); 
z = zeros(size(x));

% Step 1: Extract the zscore
switch method
    case {'normalisation', 'norm'}
        for j=1:ncols
            % find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end
            for k=start_date+period-1:nsteps   
                if std(x(k-period+1:k,j))~=0
                    z(k,j) =x(k,j)/std(x(k-period+1:k,j));
                end         
            end    
        end    
    case {'arithmetic', 'zscore arithmetic', 'za'}
        for j = 1 : ncols
            % find the first cell to start the code
            for i = 1:nsteps
                if ~isnan(x(i,j)), start_date = i;
                break
                end
            end
            for k = start_date + period - 1 : nsteps   
                if std(x(k-period+1:k,j)) ~= 0
                    z(k,j) = (x(k,j)-mean(x(k-period+1:k,j))) / std(x(k-period+1:k,j));
                end         
            end    
        end
    case {'zscore amedian', 'zmed', 'zm'}
        for j=1:ncols
            % find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end
            for k=start_date+period-1:nsteps   
                if std(x(k-period+1:k,j))~=0
                    z(k,j) =(x(k,j)-median(x(k-period+1:k,j)))/std(x(k-period+1:k,j));
                end         
            end    
        end        
    case {'fixed zscore arithmetic', 'fza', 'total period zscore arithmetic', 'tpza', 'tpzsa', 'zsatp'}
        for j=1:ncols
            % find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end
            for k=start_date+10:nsteps   
                if std(x(k-period+1:k,j))~=0
                    z(k,j) = (x(k,j) - mean(x(start_date:k,j))) / std(x(1:k,j));
                end         
            end    
        end        
    case {'fixed zscore median', 'fzm', 'total period zscore median', 'tpzm', 'tpzmed', 'tpzsm', 'tpzsmed', 'zsmtp', 'zsmedtp'}
        for j=1:ncols
            % find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end
            for k=start_date+10:nsteps   
                if std(x(k-period+1:k,j))~=0
                    z(k,j) = (x(k,j) - mean(x(start_date:k,j))) / std(x(1:k,j));
                end         
            end    
        end             
    case {'zscore exponential' , 'ze'}
        % Prelocate matrix for exponential moving average
        y = zeros(size(x));
        % Weight
        f = 2/(period+1);
        for j=1:ncols    
            % Step 1: Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end
            % Step 2.1.: First is simple moving average
            y(start_date+period-1,j) = mean(x(start_date:start_date+period-1,j)); 
            for k=start_date+period-1:start_date+period-1
                if std(x(k-period+1:k,j))~=0
                    z(k,j) =(x(k,j)-y(k,j))/std(x(k-period+1:k,j));   
                end 
            end
            % Step 2.2.: Exponential moving average
            for k=start_date+period:nsteps
                if ~isnan(x(k,j))
                    y(k,j)=f*(x(k,j)-y(k-1,j))+y(k-1,j);
                else
                    y(k,j)=y(k-1,j);
                end
                % Step 2.3. = ZScore
                if std(x(k-period+1:k,j))~=0
                    z(k,j) =(x(k,j)-y(k,j))/std(x(k-period+1:k,j));   
                end
            end                    
        end                 
end

% Step 2: Applies upper and lower bounds to the z-score
z(find(z<MinMax(1,1))) = MinMax(1,1);
z(find(z>MinMax(1,2))) = MinMax(1,2);

% Step 3.:Descend/Ascend
z=z.* DescendAscend;
