        y = zeros(1,ncols);
        yir = zeros(1,ncols);
        ytemp = zeros(size(x));
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end   
            if t > start_date(1,1)+period(1,1)+1
                for k=t-period(1,1)-period(1,2):t
                    if x(k-period(1,1),j) ~= 0 && ~isnan(x(k-period(1,1),j) )
                        ytemp(k,j) = x(k,j) / x(k-period(1,1),j) - 1;
                    end
                end  
            end
        end    
        % Volatility
        yVol= zeros(1,ncols);   
        for j=1:ncols
            y(1,j) = ytemp(t,j);
            yVol(1,j) = std(ytemp(t-period(1,2)+1:t,j));
            yir(1,j) = y(1,j) /  yVol(1,j);
        end 