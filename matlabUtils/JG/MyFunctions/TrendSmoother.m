%__________________________________________________________________________
%   
%   This function computes some classical linear and non-linear filters :
%
%   (1) ARITHMETIC MOVING AVERAGE
%   Filter 'method' = 'ama' 
%   Filter 'parameters" is the length of the lookback window
%   -----------------------------------------------------------------------
%   Example: ama10=TrendSmoother(X,'ama', 10)
%   -----------------------------------------------------------------------
%   with X a 'n * k' matrix (n observations, k variables), this gives the
%   arithmetic moving average for a 10-time-unit period
%
%   (2) EXPONENTIAL MOVING AVERAGE
%   Filter 'method' = 'ema'
%   Filter 'parameters" is the length the lookback window.
%   The weighting is f=2/(1+lookback+1)
%   -----------------------------------------------------------------------
%   Example: ema30=trendsmoother(X,'ema', 30)
%   -----------------------------------------------------------------------
%
%   (3) KAUFMAN'S ADAPTATIVE MOVING AVERAGE (volatility weighted)
%   Filter 'method' = 'kama' 
%   Filter 'parameters' are :
%        .parameters(1) an integer for the memory of the efficiency ratio
%        note: typically, between 8 and 10 days
%        .parameters(2) is the fast half-life (typically 2 or 1.5)
%        .parameters(3) is the slow half-life (typically 30 or 10)
%        note: memory < days(~ fast half-life) < days(~ slow half-life)
%   note: The Kaufman's Adaptative Moving Average (KAMA) is based on the
%   concept that a noisy market requires a slower trend than one with less
%   noise. The assumption in the KAMA is that during a relatively noisy 
%   price move, the trendline must lag further behind before being 
%   penetrated by the normal, erratic behavior of prices, which should 
%   cause an unwanted trend change. 
%   When prices move consistently in one direction with low noise, any
%   trend speed may be used because there are no false changes of direction
%   With low noise, the trendline can be positionned closer to the 
%   underlying rice direction; with higher noise, the trendline must lag 
%    farther behind.
%   -----------------------------------------------------------------------
%   Example: kama = TrendSmoother(X,'kama', [10, 2, 30])
%   -----------------------------------------------------------------------
%   Example note: the parameters are entered in a "structure": [10,2,30]
%
%   (4) CHANDES'S VARIABLE INDEX DYNAMIC AVERAGE (volatility weighted)    
%   Filter 'method' =  'vidya'
%   Filter 'parameters' are 3-fold:
%        .parameters(1) is the lookback_period for pivotal
%        smoothing (for e.g., 10 time-periods)
%        .parameters(2) is the fast memory (for e.g.,  10) to compute the
%        standard deviation of the underlying processes
%        .parameters(3) an the slow memory (for e.g.,  30) to compute the
%        standard deviation of the underlying processes
%        Note: fast memory & days(~ fast half-life)  < fast memory
%   note: Chande's Variable Index Dynamic Average (VIDYA) uses a pivotal smoothing constant, 
%   which is fixed, and varies the speed by using a factor based on the
%   relative volatility (RV), such as RV = volatility computed over a ST period / volatility
%   computed over a LT period (see parameters 2 and 3)
%   RV increases or decreases the value of f (exponential smoothing factor) defined as f=2/(lookback_period+1). 
%   The concept of the VIDYA is close from the one used in the KAMA.
%   -----------------------------------------------------------------------
%   Example: [x_trend,x_cycle] = TrendSmoother(x,'vidya', [10,10,30]);
%   -----------------------------------------------------------------------
%   Example note: the parameters are entered in a "structure": [10, 10,30]
%
%   (5) ROLLING-WINDOW TIME DETRENDER (with time over a rolling window)
%   Filter 'method' = 'time_rolling'
%   Filter 'parameters" is the length the lookback window
%   note: this detrender compute a rolling regression over a rolling period
%   (the lookback period) of the logarithm of the price. It then converts
%   back the equilibrium (filtered) log-price into the price.
%   The user can specify 2 output in order to get the detrended time series,
%   i.e. detrended time-seires = time-series - linear time trend.
%   the lookback period is typically calibrated between 20 and 100 days.
%   -----------------------------------------------------------------------
%   Example: [x_trend,x_cycle] = TrendSmoother(x,'time_rolling', 100);
%   Example: [x_trend] = trendsmoother(x,'time_rolling', 100) 
%   (if the user does not want the cyclical component);
%   -----------------------------------------------------------------------
%
%   (6) FIXED-STARTING-POINT TIME DETRENDER
%   Filter 'method' = 'time_fixed'
%   There is no Filter 'parameters'
%   note: this detrender compute a regression since a fixed starting point
%   -----------------------------------------------------------------------
%   Example: [x_trend,x_cycle] = TrendSmoother(x,'time_fixed');
%   Example: [x_trend] = TrendSmoother(x,'time_fixed');
%   (if the user does not want the cyclical component);
%   -----------------------------------------------------------------------
%
%   (7) HODRICK-PRESCOTT FILTER  
%   Filter 'method' = 'hpf'
%   Filter 'parameters' is ? (lambda)
%        A large value of ? makes the resulting series smoother, less high-frequency noise
%        monthly data:     10000 < ? < 14000
%        quarterly data:   ?= 1600
%        yearly data:      6 < ? < 14 
%        (cf. Maraval and del Rio, "Time Aggregation and the Hodrick-Prescott Filter", Bamco De Espana, 2001)
%   For daily data, use ? > 100000. It is an "art" to find the right calibration.
%   HPF delivers 2 outputs: - De-trended time series
%                           - Cyclical component
%   The user needs then to define 2 outputs (see example below).
%   note: The Hodrick-Prescott filter (HPF) is a mathematical tool used in macroeconomics,
%   especially in real business cycle theory. It is used to obtain a smoothed non-linear representation 
%   of a time series, one that is more sensitive to long-term than to short-term fluctuations. 
%   The adjustment of the sensitivity of the trend to short-term fluctuations is achieved by modifying a multiplier ? (lambda). 
%   -----------------------------------------------------------------------
%   Example: [x_trend,x_cycle] = TrendSmoother(x,'hpf', 1200);
%   -----------------------------------------------------------------------
%
%   (8) T3 TILSON MOVING AVERAGE
%   Filter 'method' =  'tilson'
%   Filter 'parameters' are 2-fold:
%        .parameters(1) is the lookback_period (for e.g., 10 time-periods)
%        .parameters(2) is the constant for weight (typically >0 and <1)      
%
%   Telson-T3 moving average is a multiple-moving-average filter. The
%   higher (lower) the constant for weight (.parameters(2)) the more
%   granular/choopier (smoother) the detrended time serie is.
%
%   -----------------------------------------------------------------------
%   Example: tilma = TrendSmoother(x,'tilson', [10,0.5]);
%   -----------------------------------------------------------------------
%
%   (9) NARARAYA-WATSON ESTIMATOR
%   Filter 'method' =  'nadaraya'
%   Filter 'parameters' is:
%        .parameters(1) is the lookback_period (for e.g., 10 time-periods)
%
%   Nadaraya-Watson Estimator is a a class of Kernel Smoothing Methods.
%   There sare "local polynomial kernel estimators". 
%   With local polynomial kernell estimator, we obtain an estimate y(o) at
%   a point x(0) by fitting a d-th degree polynomial using weighted least
%   squares. The method wants to weight the points based on their distance
%   to x(o). Those points that are closer should have greater weight, while
%   points further away have less weight. To accomplish this, we use
%   weights that are given by the height of a kernel function that is
%   centered at x(0).
%
%   Son explicit expression exist when the degree of the polynom is d=0 and
%   d=1; When d=0, we fit a constant function locally at a given point x.
%   This estimator was developped separately by Nadaraya (1964) and Watson
%   (1964).
%
%   -----------------------------------------------------------------------
%   Example: smoothed_x = TrendSmoother(x,'nadaraya', 50);
%   -----------------------------------------------------------------------
%
%   (10) LOCAL LINEAR KERNEL ESTIMATOR
%   Filter 'method' =  'loclin'
%   Filter 'parameters' is:
%        .parameters(1) is the lookback_period (for e.g., 10 time-periods)
%
%   When using Kernell smoothing methods, problems can arise near the
%   boundary of extreme edges of the sample. This hapens because the kernel
%   window at the bondaries has missing data. In other words, we have
%   weights from the kernel, but no data to assoaciate with. Wand & Jones
%   (1995) show that the local linear estimator behaves well in most cases,
%   even at the boundaries. If the Nadaray-Watson estimnator is uses, then
%   modified kernels are needed.
%
%   -----------------------------------------------------------------------
%   Example: smoothed_x = TrendSmoother(x,'loclin', 50);
%   -----------------------------------------------------------------------
%
%   (11) TIME LINE
%   Filter 'method' = 'time_line'
%   Computes a series of time-based regressions and keep the linear
%   estimate in memory.
%   Note that at a given time "t", the linear estimate from "lookback period"
%   to time=now has forward information.
%   Tgis is not an issue at the trading rule applies to the linear estimate
%   now.
%   -----------------------------------------------------------------------
%   Example: [time_line_cube] = TrendSmoother(x,'time_line', 10);
%   -----------------------------------------------------------------------
%
%   (11) TIME LINE
%   Filter 'method' = 'FixedTimeBand'
%   [b,stats] = robustfit(X,y)
%   By default, robustfit adds a first column of 1s to X, corresponding to a 
%   constant term in the model. Do not enter a column of 1s directly into X.
%   You can change the default behavior of robustfit using the input const,
%   below.
%   stats.robust_s — Robust estimate of sigma
%   mad_s — Estimate of sigma computed using the median absolute deviation 
%   of the residuals from their median; used for scaling residuals during
%   iterative fitting
%   stats.s — Final estimate of sigma, the larger of robust_s and a weighted average of ols_s and robust_s
%   stats.se — Standard error of coefficient estimates
%
%__________________________________________________________________________

function[Y1,Y2,Y3] = TrendSmoother(X, method, parameters)

% Pre-locate the matrix & Dimensions
Y1 = zeros(size(X));
Y2 = zeros(size(X));
[nbsteps,nbcols]=size(X);

switch method
    
    case {'ama','arithmetic', 'a'}
        % Step 1.: Allocate lookback_period
        lookback_period=parameters(1);        
        %Step2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                break
                end
            end
            % Step 2.2.: Moving average
            %if start_date(1,1)<length(X(:,j))-2*lookback_period+1
                for u=start_date(1,1)+lookback_period-1:nbsteps
                    Y1(u,j)=mean(X(u-lookback_period+1:u,j));
                end
            %end
        end                
        
    case {'ema', 'exponential', 'exp', 'e'}
        % Step 1.1.: Allocate lookback_period
        lookback_period=parameters(1);
        % Step 1.2.: Define Weight
        f = 2/(lookback_period+1);
        % Step 2.: Run Exponential Moving Average 
        for j=1:nbcols    
            % Step 1: Find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j)), start_date(1,1)=i;
                break
                end
            end
            % Step 2: First is simple moving average
            Y1(start_date(1,1)+lookback_period-1,j) = mean(X(start_date(1,1):start_date(1,1)+lookback_period-1,j));     
            % Then Exponential moving average
            for u=start_date(1,1)+lookback_period:nbsteps
                if ~isnan(X(u,j))
                    Y1(u,j)=f*(X(u,j)-Y1(u-1,j))+Y1(u-1,j);
                else
                    Y1(u,j)=Y(u-1,j);
                end
            end                    
        end               

    case {'med','median'}
        % Step 1.: Allocate lookback_period
        lookback_period=parameters(1);        
        %Step2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                break
                end
            end
            % Step 2.2.: Moving average
            %if start_date(1,1)<length(X(:,j))-2*lookback_period+1
                for u=start_date(1,1)+lookback_period-1:nbsteps
                    Y1(u,j)=median(X(u-lookback_period+1:u,j));
                end
            %end
        end             
        
    case 'kama'   
        % Step 1.: Model calibration - Attribute parameters
        lookback_period=parameters(1);  
        fast_period=parameters(2);   slow_period=parameters(3);
        FastSC=2/(fast_period+1);    SlowSC=2/(slow_period+1);
        % Step 2.: Pre-locate Matrix
        SSC=zeros(size(X));
        % Step 3.: Run filter
        for j=1:nbcols
            % Step 3.1.: Find the first cell to start the code
            start_date=zeros(1,1);
            for k=1:nbsteps
                if ~isnan(X(k,j))
                    start_date(1,1)=k;
                break
                end
            end
            % Step 3.2.: Compute the vector of price differences over the period p
            Y_p=zeros(nbsteps,1);
            for i=start_date(1,1) + lookback_period + 1 : nbsteps
                Y_p(i)=abs(X(i,j)-X(i-lookback_period,j));
            end    
            % Step 3.3.: Compute the vector of daily price differences
            Ydiff=zeros(nbsteps,1);
            for i=start_date(1,1)+1:nbsteps
                Ydiff(i)=abs(X(i,j)-X(i-1,j));
            end     
            % Step 3.4.: Compute the ER
            ReverseKama=1;
            ER=zeros(nbsteps,1);   
            for i=start_date(1,1)+lookback_period+1:nbsteps
                if sum(Ydiff(i-lookback_period+1:i))~=0
                    ER(i)=Y_p(i)/sum(Ydiff(i-lookback_period+1:i));
                else
                    ER(i)=ER(i-1);
                end
            end  
            % Step 3.5.: Compute the smoothing factor
            %ReverseKama=1;
            for i=start_date(1,1)+lookback_period+1:nbsteps
                %if ReverseKama==0
                    SSC(i,j)=power(ER(i)*(FastSC-SlowSC)+SlowSC,2);
                %elseif ReverseKama==1
                %    SSC(i,j)=power(ER(i)*(-FastSC+SlowSC)+SlowSC,2);
                %end
            end      
            % Step 3.6.: Compute the KAMA
            Y1(start_date(1,1)+lookback_period-1,j)=X(start_date(1,1)+lookback_period-1,j);
            for i=start_date(1,1)+lookback_period:nbsteps
                if ~isnan(Y1(i-1,j)) && ~isnan(SSC(i,j)) && ~isnan(X(i,j))
                Y1(i,j)=Y1(i-1,j)+SSC(i,j)*(X(i,j)-Y1(i-1,j));
                else
                    Y1(i,j)=Y1(i-1,j);
                end
            end
        end
        %Step 4.: Clear
        clear Y_pi ER Ydiff       
        
    case 'vidya'    
        % Step 1.1.: Allocate paramters
        lookback_period=parameters(1);
        std_short_period=parameters(2);
        std_long_period=parameters(3);           
        % Step 1.2.: Define Weight
        f = 2/(lookback_period+1);
        % Step 2.: Run Exponential Moving Average
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                end       
                break                             
            end
            % Step 2.2.: First is simple moving average
            Y1(start_date(1,1)+lookback_period-1,j) = mean(X(start_date(1,1):start_date(1,1)+lookback_period-1,j));     
            % Step 2.3.: Then Exponential moving average
            for u = start_date(1,1) + lookback_period + std_long_period : nbsteps
                % Step 2.3.1.: Compute the relative volatility
                rel_vol=std(X(u-std_short_period+1:u,j))/std(X(u-std_long_period+1:u,j));
                if ~isnan(X(u,j))
                    Y1(u,j)=f*rel_vol*X(u,j)+(1-f*rel_vol)*Y1(u-1,j);
                else
                    Y1(u,j)=Y1(u-1,j);
                end          
            end             
        end        
        Y2=Y1-X;
        
    case 'time_rolling'    
        % Step 1.1.: Allocate lookback_period
        lookback_period=parameters(1);      
        % Step 1.2.: Pre-locate second matrix of output (cyclical component)
        %Y2=zeros(size(X));        
        %Step 2.: Run filter
        % Time vector
        time_x=(1:1:lookback_period)';
        % Constant
        ct_x=ones(lookback_period,1); 
        % Concatenate Time vector & Constant
        ct_time_x =[ct_x, time_x];        
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                break
                end
            end
            % Step 2.2.: Detrend time series
            for u=start_date(1,1)+lookback_period:nbsteps
                % Natural logarithm of X
                log_x=(X(u-lookback_period+1:u,j));  
                % Compute elasticity
                b=regress(log_x, ct_time_x);  
                % Allocate (the last value of time_x=lookback_period
                log_eq_x=[1,lookback_period]*b;
                if ~isnan(log_eq_x), Y1(u,j)=exp(log_eq_x); end
            end
        end      
        % Step 3. : Detrend time series
        Y2=X-Y1;        
        
    case 'time_line'    
        % Step 1.1.: Allocate lookback_period
        lookback_period=parameters(1);  
        % Store as a cube
        %time_line=zeros(lookback_period,nbcols,nbsteps);
        Y1=zeros(lookback_period,nbcols,nbsteps);
        % Step 1.2.: Pre-locate second matrix of output (cyclical component)
        %Y2=zeros(size(X));        
        %Step 2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                break
                end
            end
            % Step 2.2.: Detrend time series
            for u=start_date(1,1)+lookback_period:nbsteps
                % Time vector
                time_x=zeros(lookback_period,1); 
                for v=1:lookback_period, time_x(v)=v; end
                % Constant
                ct_x=ones(lookback_period,1); 
                % Concatenate Time vector & Constant
                ct_time_x =[ct_x, time_x];
                % Series of lookback_period X
                log_x=(X(u-lookback_period+1:u,j));  
                % Compute elasticity
                b=regress(log_x, ct_time_x);  
                % Allocate (the last value of time_x=lookback_period
                log_eq_x=[ct_x, time_x]*b;
                Y1(1:lookback_period,j,u)=log_eq_x;
            end
        end      
        % Step 3. : Detrend time series
        %Y2=X-Y1;           
        
    case 'rolling_log'    
        % Step 1.1.: Allocate lookback_period
        lookback_period=parameters(1);      
        % Step 1.2.: Pre-locate second matrix of output (cyclical component)
        %Y2=zeros(size(X));        
        %Step 2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                break
                end
            end
            % Step 2.2.: Detrend time series
            for u=start_date(1,1)+lookback_period:nbsteps
                % Time vector
                time_x=zeros(lookback_period,1); 
                for v=1:lookback_period, time_x(v)=v; end
                % Constant
                ct_x=ones(lookback_period,1); 
                % Concatenate Time vector & Constant
                ct_time_x =[ct_x, time_x];
                % Natural logarithm of X
                log_x=log(X(u-lookback_period+1:u,j));  
                % Compute elasticity
                b=regress(log_x, ct_time_x);  
                % Allocate (the last value of time_x=lookback_period
                log_eq_x=[1,lookback_period]*b;
                if ~isnan(log_eq_x), Y1(u,j)=exp(log_eq_x); end
            end
        end      
        % Step 3. : Detrend time series
        Y2=X-Y1;          
        
    case 'time_fixed'    
        %Step 1.: Pre-locate second matrix of output (cyclical component)
        %Y2=zeros(size(X));        
        %Step 2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date=i;
                break
                end
            end
            % Step 2.2.: Detrend time series
            time_inc=10;
            for u=start_date(1,1)+10-1:nbsteps
                % Minimum of 10 points to start with
                % Update time increment
                time_inc=time_inc+1;
                % Time vector
                time_x=zeros(time_inc-1,1); 
                length_time_x=length(time_x);
                for v=1:time_inc-1, time_x(v)=v; end
                % Constant
                ct_x=ones(time_inc-1,1); 
                % Concatenate Time vector & Constant
                ct_time_x =[ct_x, time_x];
                % Natural logarithm of X
                log_x=log(X(start_date:u,j));  
                % Compute elasticity
                b=regress(log_x, ct_time_x);  
                % Allocate (the last value of time_x=lookback_period
                log_eq_x=[1,time_x(length_time_x)]*b;
                if ~isnan(log_eq_x), Y1(u,j)=exp(log_eq_x); end
            end
        end    
        % Step 3. : Detrend time series
        Y2=X-Y1;     
        
    case 'FixedTimeBand'    
        %Step 1.: Pre-locate second matrix of output (cyclical component)
        Y2=zeros(size(X));        Y3=zeros(size(X)); 
        %Step 2.: Run filter
        for j=1:nbcols
            % Step 2.1.: find the first cell to start the code
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j)), start_date=i; break ; end
            end
            % Step 2.2.: Detrend time series
            % Minimum of 10 points to start with
            MinPeriod=10;
            for u=start_date(1,1)+MinPeriod-1:nbsteps
                % Update time increment
                length_time_x=u-start_date(1,1)+1;
                % Time vector
                time_x=(start_date(1,1):1:u)';                
                % Natural logarithm of X
                ObsY=X(start_date(1,1):u,j);  
                % Compute elasticity
                [b,stats]=robustfit(time_x,ObsY);  
                % Allocate (the last value of time_x=lookback_period
                EqY=[1,time_x(length_time_x)]*b;
                if ~isnan(EqY), 
                    Y1(u,j)=EqY; 
                else
                    Y1(u,j)=Y1(u-1,j);
                end
                MyS=stats.s;
                if ~isnan(MyS), 
                    Y2(u,j)=MyS; 
                else
                    Y2(u,j)=Y2(u-1,j);
                end       
                MySe=stats.se(1,1);
                if ~isnan(MyS), 
                    Y3(u,j)=MySe; 
                else
                    Y3(u,j)=Y3(u-1,j);
                end                  
                
            end
        end    
        % Step 3. : Detrend time series
        Y2=X-Y1;         
        
    case 'hpf'
        % Step 1.: Allocate paramters
        lambda=parameters(1);
        % Step 2. Pre-locate second matrix of output (cyclical component)
        Y2=zeros(size(X));
        % Step 3. : Run the HP Filter
        for j=1:nbcols
            % Step 3.1.: Identify the 1st non-empty cell
            start_date=zeros(1,1);
            for i=1:nbsteps
                if ~isnan(X(i,j))
                    start_date(1,1)=i;
                    break
                end
            end     
            % Step 3.1.:  Start algo
            % note: Y1 is the de-trended time-series. 
            % It makes use of the function hpfilter'
            final_step=nbsteps-start_date(1,1);
            for i=29:final_step
                my_vector=X(start_date(1,1):start_date(1,1)+i,j);
                my_hp=HPFilter(my_vector,lambda);
                n=length(my_hp);
                Y1(start_date+i,j)=my_hp(n);
            end
        end
        % Step 4.: Compute difference
        % note: Y2 is the Cyclical component
        for j=1:nbcols
            for i=1:nbsteps
                if Y1(i,j)~=0 && ~isnan(Y1(i,j)) && ~isnan(X(i,j))
                    Y2(i,j)=X(i,j)/Y1(i,j)-1;
                end
            end
        end        
    
    case 'tilson'
        % Step 1.1.: Allocate lookback_period
        lookback_period=parameters(1);
        volfactor=parameters(2);        
        % Step 1.2.: First moving average
        ema1o=expmav(X,lookback_period);
        ema2o=expmav(ema1o,lookback_period);
        % MME3
        ema3o=expmav(ema2o,lookback_period);
        % MME4
        ema4o=expmav(ema3o,lookback_period);   
        % MME5
        ema5o=expmav(ema4o,lookback_period); 
        % MME6
        ema6o=expmav(ema5o,lookback_period);         
        % Parameters
        c1 = - (volfactor)^3;
        c2 = 3 * (volfactor)^2 + 3 * (volfactor)^3;
        c3 = - 6 * (volfactor)^2 - 3 * volfactor - 3 * (volfactor)^3;
        c4 = 1 + 3 * volfactor + (volfactor)^3 + 3 *(volfactor)^2;
        Y1 = c1*ema6o + c2 *ema5o + c3*ema4o + c4*ema3o;  
        clear ema1o ema2o ema3o ema4o ema5o ema6o
        
    case 'nadaraya'
        % Step 1. Set up the space to store the estimated values. 
        % This will get the estimates at all values of x
        Y1=zeros(size(X));
        % Step 2: Set the Time & Constant vector
            % Step 2.1.: Allocate lookback_period
            lookback_period=parameters(1);           
            % Step 2.2.: Time vector
            time_x=zeros(lookback_period,1);
            for v=1:lookback_period, time_x(v)=v; end
            % Step 2.2.: Constant
            %ct_x=ones(lookback_period,1);   
            % Step 2.3.:Concatenate Time vector & Constant
            %ct_time_x =[ct_x, time_x];    
        % Step 3: Run Rolling Nadaraya
        % Step 3.1.: Set the window width
        h=1;    
        %deg=0;        
        % Step 3.2.: Create an inline function to evalue the weights
        % (with Normal Kernel)
        mystrg='(2*pi*h^2)^(-1/2)*exp(-0.5*((time_x-mu)/h).^2)';
        wfun=inline(mystrg);  
        % Step 3.3.: Find smooth at each value in x           
        for j=1:nbcols
            for i=1+lookback_period:nbsteps          
                w=wfun(h,time_x(length(time_x)),time_x);
                myX=X(i-lookback_period+1:i,j);                   
                Y1(i,j)=sum(w.*myX)/sum(w);
            end
        end
        % Step 4.: Detrend & Clean
        %Y2=X-Y1;
        %for j=1:nbcols, for i=1:nbsteps, if Y1(i,j)==0, Y2(i,j)=0; end, end, end
        
        
    case 'loclin'
        % Step 1. Set up the space to store the estimated values. 
        % This will get the estimates at all values of x
        Y1=zeros(size(X));
        % Step 2: Set the Time & Constant vector
            % Step 2.1.: Allocate lookback_period
            lookback_period=parameters(1);           
            % Step 2.2.: Time vector
            time_x=zeros(lookback_period,1);
            for v=1:lookback_period, time_x(v)=v; end
            % Step 2.2.: Constant
            %ct_x=ones(lookback_period,1);   
            % Step 2.3.:Concatenate Time vector & Constant
            %ct_time_x =[ct_x, time_x];    
        % Step 3.: Run Rolling Local Linear Kernel
        % Step 3.1.: Set the window width
        h=1;  
        %deg=1;
        % Step 3.2.: Create an inline function to evalue the weights (with
        % Normal Kernel)
        mystrg='(2*pi*h^2)^(-1/2)*exp(-0.5*((time_x-mu)/h).^2)';
        wfun=inline(mystrg);            
        for j=1:nbcols
            for i=1+lookback_period:nbsteps
                % Step 4. Find smooth at each value in x             
                w=wfun(h,time_x(length(time_x)),time_x);
                time_x_c=time_x-time_x(length(time_x));
                s2=sum(time_x_c.^2.*w)/lookback_period;
                s1=sum(time_x_c.*w)/lookback_period;
                s0=sum(w)/lookback_period;
                myX=X(i-lookback_period+1:i,j);                   
                Y1(i,j)=sum(((s2-s1*time_x_c).*w.*myX)/(s2*s0-s1^2))/lookback_period;
            end
        end        
        % Step 4.: Detrend & Clean
        %Y2=X-Y1;
        %for j=1:nbcols, for i=1:nbsteps, if Y1(i,j)==0, Y2(i,j)=0; end, end, end    
            
end

