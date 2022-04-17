function [z]=spearmanx2y(x,y,lag_x, lag_y, period)

% Identify dimensions
[nsteps,ncols]=size(x);

for j=1:ncols
    
    for i=1:nsteps
        
        % Extract vector
        x_vect=x(i-period - lag_x + 1: i- lag_x, j);
        y_vect=y(i-period - lag_y + 1: i- lag_y, j);      
        
        % Compute the ranks
        rank_x=nrank1(x_vect,1)';
        % Clean first if duplicate.............................
        fixOrder = 0;
        [tmpSortedArr tmpSortIdx] = sort(rank_x);
        for loop=2:size(rank_x,2)
            if (rank_x(tmpSortIdx(loop)) == rank_x(tmpSortIdx(loop-1)) && ~isnan(rank_x(tmpSortIdx(loop))))    % Two elements the same
                fixOrder = 1;
                for loop2=loop:size(rank_x,2)
                    if (~isnan(rank_x(tmpSortIdx(loop2))))
                        rank_x(tmpSortIdx(loop2)) = rank_x(tmpSortIdx(loop2))+1;
                    end
                end
            end
        end
        if (fixOrder == 1)
            counter = 2;
            for loop=2:size(rank_x,2)
                if (~isnan(rank_x(tmpSortIdx(loop))))
                    rank_x(tmpSortIdx(loop)) = counter;
                    counter = counter + 1;
                end
            end
        end     
        %......................................................  
        % Transpose
        rank_x=rank_x';
        
        % Compute the ranks
        rank_y=nrank1(y_vect,1)';
        % Clean first if duplicate.............................
        fixOrder = 0;
        [tmpSortedArr tmpSortIdx] = sort(rank_y);
        for loop=2:size(rank_y,2)
            if (rank_y(tmpSortIdx(loop)) == rank_y(tmpSortIdx(loop-1)) && ~isnan(rank_y(tmpSortIdx(loop))))    % Two elements the same
                fixOrder = 1;
                for loop2=loop:size(rank_y,2)
                    if (~isnan(rank_y(tmpSortIdx(loop2))))
                        rank_y(tmpSortIdx(loop2)) = rank_y(tmpSortIdx(loop2))+1;
                    end
                end
            end
        end
        if (fixOrder == 1)
            counter = 2;
            for loop=2:size(rank_y,2)
                if (~isnan(rank_y(tmpSortIdx(loop))))
                    rank_y(tmpSortIdx(loop)) = counter;
                    counter = counter + 1;
                end
            end
        end     
        %......................................................    
        % Transpose
        rank_y=rank_y';        
        
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
        spearman_corr=1- 6*my_sum / (period*(power(period,2)-1));
        % Assign
        z(i,j)=spearman_corr;
        
    end
    
end
        
        