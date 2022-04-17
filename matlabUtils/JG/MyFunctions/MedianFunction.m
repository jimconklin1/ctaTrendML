function[medx,NormMedianSpread] = MedianFunction(X, lookback_period, period_vol, MedianSpreadLevOrDif)
%
%__________________________________________________________________________
%The function computes the Median and the normlaised difference of the
%variable versus the median
%
%__________________________________________________________________________

[nbsteps,nbcols] = size(X); 
medx=zeros(size(X));
NormMedianSpread=zeros(size(X));

for j=1:nbcols
    % Step 2.1.: find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j))
            start_date(1,1)=i;
        break
        end
    end

    % Step 2.2.: Median
    %if start_date(1,1)<length(X(:,j))-2*lookback_period+1
        for i=start_date(1,1)+lookback_period-1:nbsteps
            medx(i,j)=median(X(i-lookback_period+1:i,j));
        end
    %end
    
    %if nargout>1
        % Volatility
        if MedianSpreadLevOrDif==1
                % Compute Volatility
            std_c = VolatilityFunction(X,'std',period_vol,3,10e10);
            for i=2:length(std_c)
                if std_c(i)==0 || std_c(i)==Inf || std_c(i)==-Inf || isnan(std_c(i))
                    std_c(i)=std_c(i-1);
                end
            end
            VolForMedianModel=std_c;
            clear std_c
        elseif MedianSpreadLevOrDif==2
            c1dd = RateofChange(X,'difference',1);
            % Compute Volatility
            std_c1dd = VolatilityFunction(c1dd,'std',period_vol,3,10e10);
            for i=2:length(std_c1dd)
                if std_c1dd(i)==0 || std_c1dd(i)==Inf || std_c1dd(i)==-Inf || isnan(std_c1dd(i))
                    std_c1dd(i)=std_c1dd(i-1);
                end
            end
            VolForMedianModel=std_c1dd;
            clear std_c1dd  
        end
        
        % Compute Centered Spread on Median
        MedianSpread = X - medx;
        
        % Normalised Centered Spread
        NormMedianSpread = MedianSpread ./ VolForMedianModel;    
        
        % Clean
        for i=2:length(NormMedianSpread)
            if NormMedianSpread(i)==Inf || NormMedianSpread(i)==-Inf || isnan(NormMedianSpread(i))
                NormMedianSpread(i)=0;
            end
        end    
        for i=2:length(NormMedianSpread)
            if  NormMedianSpread(i)==Inf || NormMedianSpread(i)==-Inf || isnan(NormMedianSpread(i))
                NormMedianSpread(i)=NormMedianSpread_c(i-1);
            end
        end       
        
    %end
    
end    
   