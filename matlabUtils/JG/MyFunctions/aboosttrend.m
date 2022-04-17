%
%__________________________________________________________________________
%
% Trend forecast "lag" periods ahead
% with Adaboost
% -- Output --
% y    = forecast class (+1: positive return, -1; negative return)
% pcty = goodness of the fit (percentage of rightly classified returns'
% class)
%__________________________________________________________________________
%
%

function [y, pcty] = aboosttrend(x, lag, lookback)

% -- Create parallel pool on cluster --
parpool(8)

% -- Dimensions & Prelocation of matrices --
[nsteps,ncols]=size(x);
y = zeros(size(x));    % class
pcty = zeros(size(x)); % goodness of the fit

% -- Forecast lag periods ahead --
for j=1:ncols
    
    % -- Snap --
    xj = x(:,j);
    
    % -- Compute Sign forcast @ given lag --
    dxj = sign(Delta(xj, 'd', lag));
    
    % -- Create factors for forecast --
    
    % Moving averages
    ma2 = expmav(xj, 2);
    ma3 = expmav(xj, 3);
    ma5 = expmav(xj, 5);
    ma8 = expmav(xj, 8);
    ma13 = expmav(xj, 13);
    ma21 = expmav(xj, 21);
    ma34 = expmav(xj, 34);
    ma55 = expmav(xj, 55);
    ma89 = expmav(xj, 89);
    ma144 = expmav(xj, 144);
    ma233= expmav(xj, 233);
    
    % Compute sign difference in pair-wise moving averages      
    dma1 = sign(xj - ma5);
    dma2 = sign(xj - ma8);
    dma3 = sign(xj - ma13);
    dma4 = sign(ma2 - ma8);   
    dma5 = sign(ma2 - ma13); 
    dma6 = sign(ma3 - ma13); 
    dma7 = sign(ma3 - ma21); 
    dma8 = sign(ma3 - ma34); 
    dma9 = sign(ma3 - ma55); 
    dma10 = sign(ma5 - ma21); 
    dma11 = sign(ma5 - ma34); 
    dma12 = sign(ma5 - ma55); 
    dma13 = sign(ma8 - ma34); 
    dma14 = sign(ma8 - ma55); 
    dma15 = sign(ma13 - ma55); 
    dma16 = sign(ma13 - ma89); 
    dma17 = sign(ma13 - ma144); 
    dma18 = sign(ma21 - ma89); 
    dma19 = sign(ma21 - ma144); 
    dma20 = sign(ma21 - ma233); 

    % Trend strength based on Variance Ratio Test
    vr1 = RollingVRTest(xj, 5, 'het');
    vr2 = RollingVRTest(xj, 8, 'het');
    vr3 = RollingVRTest(xj, 13, 'het');
    vr4 = RollingVRTest(xj, 21, 'het');
    vr5 = RollingVRTest(xj, 34, 'het');
    vr6 = RollingVRTest(xj, 55, 'het');
    vr7 = RollingVRTest(xj, 89, 'het');
    vr8 = RollingVRTest(xj, 144, 'het');
    vr9 = RollingVRTest(xj, 233, 'het');
    
    % Identify start date
    startDate = zeros(1,1);
    for i=1:nsteps
        if xj(i)~=0 
            startDate(1,1)=i;
            break
        end
    end
    
    % -- Trend forecast based on Adaboost --
    parfor i=startDate(1,1)+lookback+lag:nsteps
        % Extract feature
        dataFeatures = [dma1(i-lookback+1-lag:i-lag),  dma2(i-lookback+1-lag:i-lag),  dma3(i-lookback+1-lag:i-lag),  dma4(i-lookback+1-lag:i-lag),  dma5(i-lookback+1-lag:i-lag), ...
                        dma6(i-lookback+1-lag:i-lag),  dma7(i-lookback+1-lag:i-lag),  dma8(i-lookback+1-lag:i-lag),  dma9(i-lookback+1-lag:i-lag),  dma10(i-lookback+1-lag:i-lag), ...
                        dma11(i-lookback+1-lag:i-lag), dma12(i-lookback+1-lag:-lag),  dma13(i-lookback+1-lag:i-lag), dma14(i-lookback+1-lag:i-lag), dma15(i-lookback+1-lag:i-lag), ...
                        dma16(i-lookback+1-lag:i-lag), dma17(i-lookback+1-lag:i-lag), dma18(i-lookback+1-lag:i-lag), dma19(i-lookback+1-lag:i-lag), dma20(i-lookback+1-lag:i-lag), ...
                        vr1(i-lookback+1-lag:i-lag),   vr2(i-lookback+1-lag:i-lag),  vr3(i-lookback+1-lag:i-lag),    vr4(i-lookback+1-lag:i-lag),   vr5(i-lookback+1-lag:i-lag), ...
                        vr6(i-lookback+1-lag:i-lag),   vr7(i-lookback+1-lag:i-lag),  vr8(i-lookback+1-lag:i-lag),    vr9(i-lookback+1-lag:i-lag)];
%         dataFeatures = [dma8(i-lookback+1-lag:i-lag),   dma10(i-lookback+1-lag:i-lag), dma13(i-lookback+1-lag:i-lag), dma15(i-lookback+1-lag:i-lag), ...
%                         dma16(i-lookback+1-lag:i-lag), dma17(i-lookback+1-lag:i-lag), dma18(i-lookback+1-lag:i-lag), dma19(i-lookback+1-lag:i-lag), dma20(i-lookback+1-lag:i-lag), ...
%                         vr1(i-lookback+1-lag:i-lag),   vr2(i-lookback+1-lag:i-lag),  vr3(i-lookback+1-lag:i-lag),    vr4(i-lookback+1-lag:i-lag),   vr5(i-lookback+1-lag:i-lag), ...
%                         vr6(i-lookback+1-lag:i-lag),   vr7(i-lookback+1-lag:i-lag),  vr8(i-lookback+1-lag:i-lag),    vr9(i-lookback+1-lag:i-lag)];                    
        % Train retuns
        dataClass = dxj(i-lookback+1:i);  
        % Train Adaboost
        [classEstimate, model_ij]=adaboost('train', dataFeatures, dataClass, 10);        
        % Classify the testdata with the trained model
        dataFeatures_i = [dma1(i),  dma2(i),  dma3(i),  dma4(i),  dma5(i), dma6(i),  dma7(i),  dma8(i),  dma9(i),  dma10(i), ...
                    dma11(i), dma12(i-lookback+1-lag:-lag),  dma13(i), dma14(i), dma15(i), dma16(i), dma17(i), dma18(i), dma19(i), dma20(i), ...
                    vr1(i),   vr2(i),  vr3(i),    vr4(i),   vr5(i), vr6(i),   vr7(i),  vr8(i),    vr9(i)];
        % Forecasat class "lag" peridos ahead
        forecastClass = adaboost('apply', dataFeatures_i, model_ij);      
        % Assign to output
        y(i,j) = forecastClass;
    end
    
    % -- Compute goodness of the fit --
    forecastJunk = zeros(nsteps,1);    forecastJunk(lag+1:nsteps) = y(1:nsteps-lag,j); 
    forecastJunk(1:lookback+lag)=zeros(lookback+lag,1);
    dxj(1:lookback+lag)=zeros(lookback+lag,1);
    forecastDiff = sign(abs(forecastJunk - dxj));     % Difference between forecast class and realized class (good forecast = 0)
    forecastDiffSum = cumsum(forecastDiff);           % Cumulated sum of differences (if all good, 0)
    badClass = forecastDiffSum ./ (1:nsteps)';        % Percentage of miss-classification
    pcty(:,j) = 100 * (ones(nsteps,1) -  badClass);   % Goodness of the fit (percentage of right classification)
    
    
end

