function[z] = cor2v(x,y,lag_x,lag_y,period,method)
%
%__________________________________________________________________________
% The function computes the correlation between two variables
%
% Tow methodologies ('method') are possible:
% - Pearson (parametric)
% - Spearman (rank correlation, non parametric)
% 
% INPUT
% - x       = first  'n observations X m assets' matrix
% - y       = second 'n observations X m assets' matrix
% - period  = period over which the correlation is computed
%__________________________________________________________________________
%
% -- Prelocate Matrix & Dimensions --
z = zeros(size(x));
[nsteps,ncols]=size(x);
%
switch method
    case 'pearson'
        % Lag Structure
        x(lag_x+1:nsteps,:)=x(1:nsteps-lag_x,:);
        y(lag_y+1:nsteps,:)=y(1:nsteps-lag_y,:);
        MaxLag=max(lag_x,lag_y);
        for j=1:ncols
            % Find the first cell to start the code
            for i=MaxLag+1:nsteps
                if ~isnan(x(i,j)) && ~isnan(y(i,j))
                    StartDate=i;
                break
                end
            end
            % Auto-correlation
            for i=StartDate+period-1+1:nsteps
                z(i,j)=corr(x(i-period+1:i,j),y(i-period+1:i,j));
            end
        end
    case {'covar', 'covariance'}
        % Lag Structure
        x(lag_x+1:nsteps,:)=x(1:nsteps-lag_x,:);
        y(lag_y+1:nsteps,:)=y(1:nsteps-lag_y,:);
        MaxLag=max(lag_x,lag_y);
        for j=1:ncols
            % Find the first cell to start the code
            for i=MaxLag+1:nsteps
                if ~isnan(x(i,j)) && ~isnan(y(i,j))
                    StartDate=i;
                break
                end
            end
            % Auto-correlation
            for i=StartDate+period-1+1:nsteps
                z(i,j)=cov(x(i-period+1:i,j),y(i-period+1:i,j));
            end
        end        
    case 'spearman'
        for j=1:ncols
            for i=period:nsteps
                % Extract vector
                x_vect=x(i-period - lag_x + 1: i- lag_x, j);
                y_vect=y(i-period - lag_y + 1: i- lag_y, j);      
                % Compute the ranks
                rank_x=NominalRank(x_vect,'excel'); 
                % Compute the ranks
                rank_y=NominalRank(y_vect,'excel'); 
                % Compute the the sum of the suqred differences in ranks
                dif_vector=zeros(size(period,1));
                for u=1: length(dif_vector)
                    dif_vector=power(rank_x(u,1)-rank_y(u,1),2);
                end
                % Compute the sum
                if ~isnan(sum(dif_vector))
                    my_sum=sum(dif_vector);
                else
                    my_sum=0;
                end

                % Compute Spearman
                spearman_corr = 1- 6*my_sum / (period*(power(period,2)-1));
                % Assign
                z(i,j)=spearman_corr;
            end
        end 
end