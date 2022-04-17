function z = newPercentile(x, method, lookback)

%__________________________________________________________________________
%__________________________________________________________________________

[nsteps,ncols] = size(x); % dimension
z = zeros(nsteps,ncols);  % prelocation

if strcmp(method,'rolling')    
    for j=1:ncols
        xSnap = x(:,j);
        for i=lookback:nsteps
            xSnap_i = xSnap(i-lookback+1:i);
            xLength = size(xSnap_i,1);
            min1 = min(xSnap_i);
            max1 = max(xSnap_i);
            index_Dif = (xSnap_i - repmat(min1,xLength,1)) ./ (repmat(max1,xLength,1) - repmat(min1,xLength,1));
            percentile_index_Dif  = (tiedrank(index_Dif) - 1) / (xLength - 1);
            z(i,j) = 100*percentile_index_Dif(end);
        end
    end
elseif strcmp(method,'fixed')
    for j=1:ncols
        xSnap = x(:,j);
        xLength = size(xSnap,1);
        min1 = min(xSnap);
        max1 = max(xSnap);
        index_Dif = (xSnap - repmat(min1,xLength,1)) ./ (repmat(max1,xLength,1) - repmat(min1,xLength,1));
        percentile_index_Dif  = 100*(tiedrank(index_Dif) - 1) / (xLength - 1);
        z(:,j) = 100*percentile_index_Dif;
    end    
end
