function[Y,Z] = VolatilityFunctionSnap(t, X,method,Period,PeriodAvgPrice,Troncate)
%__________________________________________________________________________
% The function computes many measures of Volatility usually computed for
% financial assets
%
% - 'simple volatility', 'std' :       
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
% - 'efficiency ratio':
%       standard deviation of the price divided by the moving average of
%       the price price
% - 'Parkinson':
%       standard deviation of the price divided by the moving average of
%       the price price
%
% -- INPUT --
% x = series of close price
%__________________________________________________________________________
%
% -- Dimension & Prelocate matrices --
[nsteps,ncols] = size(X); 
Y = zeros(1,ncols);
Z = zeros(1,ncols);
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
        Y(1,j) = std(X(t-Period+1:t,j));
    end
end
% -- Compute Volatility with Different methods --
switch method
    case {'variance', 'var'}
        Y = Y.*Y;       
    case {'std', 'standard deviation', 'simple volatility'}
        Y = Y;     
    case {'volatility to spot price' , 'v2p', 'v2sp', 'std2sp'}
        Y = Y ./ X(t,:);
    case {'volatility to average price' , 'vol2avgp', 'std2avgp'}
        AX = expmav(X,Period);        
        Y = Y ./ AX(t,:);  
    case {'average volatility to average price' , 'avgvol2avgp', 'avgstd2avgp'}
        AY = expmav(Y,PeriodAvgPrice);
        AX = expmav(X,Period);        
        Y = AY ./ AX; 
    case {'volatility daily return' , 'vol-day-ret' , 'voldayret' ,'voldret', 'stddret'}
        d1r = RateofChange(X,'rate of change',1);
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
                Y(1,j) = std(d1r(t-Period+1:t,j));
            end
        end         
%     case {'efficiency ratio', 'er' , 'efratio'}
%         for j=1:ncols
%             % Find starting point
%             for k=1:nsteps
%                 if ~isnan(X(k,j))
%                     start_date=k;
%                     break
%                 end
%             end
%             % Compute efifciency ratio
%             for i = start_date + Period : nsteps
%                 mydiff = abs(X(i,j)-X(i-Period+1,j));
%                 mycount=0;
%                 for u=i-Period+1:i
%                     mycount = mycount + abs(X(u,j)-X(u-1,j));
%                 end
%                 if ~isnan(mydiff) && ~isnan(mycount) && mycount~=0
%                     Y(i,j) = mydiff / mycount;
%                 end
%             end
%         end
%     % -- Smotth volatility estimate --
%     Z = expmav(Y,PeriodAvgPrice);      
end
%
% -- Delete extremes --
Y(find(Y>Troncate)) = Troncate;   