function[Y,Z] = fvol(X,method,Period,PeriodAvgPrice,Troncate)
%__________________________________________________________________________
% The function computes the Volatility of a stock in several different ways
%
% - 'simple volatility' :       
%       standard deviation of the price
% - 'volatility to spot price':
%       standard deviation of the price divided by the price
% - 'volatility to spot average price':
%       standard deviation of the price divided by the moving average
%       of the price price
% - 'average volatility to average price':
%       standard deviation of the price divided by the moving average of
%       the price price
% - 'volatility daily return':
%       standard deviation of the price divided by the moving average of
%       the price price
% - 'Parkinson':
%       standard deviation of the price divided by the moving average of
%       the price price
% - 'efficiency ratio':
%       standard deviation of the price divided by the moving average of
%       the price price
%__________________________________________________________________________
%
%X=macdd;
%method='simple volatility';
%Period=20;SmoothPeriod=20;Troncate=1;
%
[nsteps,ncols] = size(X); 
Y = zeros(size(X));
Z = zeros(size(X));
%
for j=1:ncols
    start_date=zeros(1,1);
    % Step 1: find the first cell to start the code  
    for i=Period:nsteps      
        if ~isnan(X(i,j))
            start_date(1,1)=i;  
            break
        end
    end
    % Step 2: Compute standard deviation
    if nsteps>Period
        for k=start_date(1,1)+Period:nsteps
            Y(k,j) = std(X(k-Period+1:k,j));
        end
    end
end
% -- Compute Volatility with Different method
switch method
    case {'simple volatility',  'std'}
        Y=Y;     
    case 'volatility to spot price'
        Y=Y./X;
    case {'volatility to average price' , 'vol2avgp'}
        AX=expmav(X,Period);        
        Y=Y./AX;  
    case {'average volatility to average price' , 'avgvol2avgp'}
        AY=expmav(Y,PeriodAvgPrice);
        AX=expmav(X,Period);        
        Y=AY./AX; 
    case {'volatility daily return' , 'vol-day-ret' , 'voldayret' ,'voldret'}
        d1r=RateofChange(X,'rate of change',1);
        for j=1:ncols
            start_date=zeros(1,1);
            % Step 1: find the first cell to start the code  
            for i=Period:nsteps      
                if ~isnan(d1r(i,j))
                    start_date(1,1)=i;  
                    break
                end
            end
            if nsteps>Period
                % Step 2: Compute standard deviation
                for k=start_date(1,1)+Period:nsteps
                    Y(k,j) = std(d1r(k-Period+1:k,j));
                end
            end
        end         
    case {'efficiency ratio', 'er' , 'efratio'}
        for j=1:ncols
            % Find starting point
            for k=1:nsteps
                if ~isnan(X(k,j))
                    start_date=k;
                    break
                end
            end
            % Compute efifciency ratio
            for i = start_date + Period : nsteps
                mydiff=abs(X(i,j)-X(i-Period+1,j));
                mycount=0;
                for u=i-Period+1:i
                    mycount=mycount+abs(X(u,j)-X(u-1,j));
                end
                if ~isnan(mydiff) && ~isnan(mycount) && mycount~=0
                    Y(i,j)=mydiff/mycount;
                end
            end
        end
    % Smotth efficiency ratio
    Z=expmav(Y,PeriodAvgPrice);      
end
% Delete extreme
Y(find(Y>Troncate)) = Troncate;   