%function [ye,see,yf,sef] = SmoothPolynomial(x, parameters)
parameters=[32,1];x=c;
%__________________________________________________________________________
%
% Compute the Estimated & Slope for two variable x & y
%
% INPUTS:
%
% - parameters: a structure of 1 row and 2 columns or 1 column
%       . parameters(1) is always the lookback period for the rolling
%       regression
%       . parameters(2) is 1 (or ommited by default) if you want to put a
%       constant in the model regress
% - Use x as the regressor (the predictor) and y as the regresand
% (predicted)
%
% Watch out the difference in writting the functions 'regress' and
% 'robustfit'
% -- Regress method --
% b = regress(y,X) (responses in y on the predictors in X)
% When computing statistics, X should include a column of 1s so that the
% model contains a constant 

%__________________________________________________________________________


% -- Define Parameters --
nsteps = size(x,1);  
ye = zeros(nsteps,6);   see = zeros(nsteps,4);  % smoothing, estimation
yf = zeros(nsteps,6);   sef = zeros(nsteps,4);  % forecast
if size(parameters,2) == 1
    lookback_period = parameters(1,1);  
    intercept = 0;
elseif size(parameters,2) == 2
    lookback_period=parameters(1,1); 
    intercept = 1;
    ct_x = ones(lookback_period,1);  
end
% Find the first cell to start the code
start_date = zeros(1,1);
for i=1:nsteps
    if ~isnan(x(i))  && x(i)~=0 
        start_date(1,1) = i;
    break
    end
end
    
for i=start_date(1,1)+lookback_period+1:nsteps
    % Use 1-day lag to forecast next day
    snap_x_1dl = x(i-lookback_period+1-1:i-1); 
    snap_x_1dl_p2 = power(snap_x_1dl,2);
    snap_x_1dl_p3 = power(snap_x_1dl,3);
    snap_x_1dl_p4 = power(snap_x_1dl,4);
    % Use total sample for smoothing
    snap_x = x(i-lookback_period+1:i); 
    snap_x_p2 = power(snap_x,2);
    snap_x_p3 = power(snap_x,3);
    snap_x_p4 = power(snap_x,4);    
    if intercept == 1
        % Build polynoms - Use 1-day lag to forecast next day
        snap_x_1dl_po1 = [ct_x, snap_x_1dl];
        snap_x_1dl_po2 = [ct_x, snap_x_1dl, snap_x_1dl_p2];
        snap_x_1dl_po3 = [ct_x, snap_x_1dl, snap_x_1dl_p2, snap_x_1dl_p3];
        snap_x_1dl_po4 = [ct_x, snap_x_1dl, snap_x_1dl_p2, snap_x_1dl_p3, snap_x_1dl_p4];
        % Build polynoms - Use total sample for smoothing
        snap_x_po1 = [ct_x, snap_x];
        snap_x_po2 = [ct_x, snap_x, snap_x_p2];
        snap_x_po3 = [ct_x, snap_x, snap_x_p2, snap_x_p3];
        snap_x_po4 = [ct_x, snap_x, snap_x_p2, snap_x_p3, snap_x_p4];        
    elseif intercept == 0
        snap_x_1dl_po1 = snap_x_1dl;
        snap_x_1dl_po2 = [snap_x_1dl, snap_x_1dl_p2];
        snap_x_1dl_po3 = [snap_x_1dl, snap_x_1dl_p2, snap_x_1dl_p3];
        snap_x_1dl_po4 = [snap_x_1dl, snap_x_1dl_p2, snap_x_1dl_p3, snap_x_1dl_p4];        
        snap_x_po1 = snap_x;
        snap_x_po2 = [snap_x, snap_x_p2];
        snap_x_po3 = [snap_x, snap_x_p2, snap_x_p3];
        snap_x_po4 = [snap_x, snap_x_p2, snap_x_p3, snap_x_p4];        
    end            
    % Snap data for y
    snap_y = x(i-lookback_period+1:i);              
    % Regress for estimating / smoothing
        % Order 1
        [b,~,~,~,stats] = regress(snap_y, snap_x_po1);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 1
            ye(i,1) = b' * snap_x_po1(size(snap_x_po1,1),:)';
            see(i,1) = stats(1,4);
        else
            ye(i,1) = ye(i-1,1);
            see(i,1) = see(i-1,1);
        end
        % Order 2
        [b,~,~,~,stats] = regress(snap_y, snap_x_po2);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 2
            ye(i,2) = b' * snap_x_po2(size(snap_x_po2,1),:)';
            see(i,2) = stats(1,4);
        else
            ye(i,2) = ye(i-1,2);
            see(i,1) = see(i-1,2);
        end 
        % Order 3
        [b,~,~,~,stats] = regress(snap_y, snap_x_po3);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 3
            ye(i,3) = b' * snap_x_po3(size(snap_x_po3,1),:)';
            see(i,3) = stats(1,4);
        else
            ye(i,3) = ye(i-1,3);
            see(i,3) = see(i-1,3);
        end
        % Order 4
        [b,~,~,~,stats] = regress(snap_y, snap_x_po4);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 4
            ye(i,4) = b' * snap_x_po4(size(snap_x_po4,1),:)';
            see(i,4) = stats(1,4);
        else
            ye(i,4) = ye(i-1,4);
            see(i,4) = see(i-1,4);
        end     
    % Regress for forecast (estimate with 1 day lag, forecast with current)
        % Order 1
        [b,~,~,~,stats] = regress(snap_y, snap_x_1dl_po1);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 1
            yf(i,1) = b' * snap_x_po1(size(snap_x_po1,1),:)';
            sef(i,1) = stats(1,4);
        else
            yf(i,1) = yf(i-1,1);
            sef(i,1) = sef(i-1,1);
        end
        % Order 2
        [b,~,~,~,stats] = regress(snap_y, snap_x_1dl_po2);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 2
            yf(i,2) = b' * snap_x_po2(size(snap_x_po2,1),:)';
            sef(i,2) = stats(1,4);
        else
            yf(i,2) = yf(i-1,2);
            sef(i,1) = sef(i-1,2);
        end 
        % Order 3
        [b,~,~,~,stats] = regress(snap_y, snap_x_1dl_po3);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 3
            yf(i,3) = b' * snap_x_po3(size(snap_x_po3,1),:)';
            sef(i,3) = stats(1,4);
        else
            yf(i,3) = yf(i-1,3);
            sef(i,3) = sef(i-1,3);
        end
        % Order 4
        [b,~,~,~,stats] = regress(snap_y, snap_x_1dl_po4);  
        % Allocate (the last value of time_x=lookback_period
        if size(b,1) == intercept + 4
            yf(i,4) = b' * snap_x_po4(size(snap_x_po4,1),:)';
            sef(i,4) = stats(1,4);
        else
            yf(i,4) = yf(i-1,4);
            sef(i,4) = sef(i-1,4);
        end           
end
% Simple average estimate
ye(:,5)=(ye(:,1)+ye(:,2)+ye(:,3)+ye(:,4))/4;
yf(:,5)=(yf(:,1)+yf(:,2)+yf(:,3)+yf(:,4))/4;
for i=1:nsteps
    ye(i,6)=power(see(i,:),-1)*ye(i,1:4)'/sum(power(see(i,:),-1),2);
    yf(i,6)=power(sef(i,:),-1)*yf(i,1:4)'/sum(power(sef(i,:),-1),2);
end
% Inveerse variance estimate
yf(isnan(yf))=0;
ye(isnan(ye))=0;
pl=zeros(size(c));
for i=2:nsteps-1
    if yf(i,1)<yf(i,6) && c(i)<ye(i,6)
        pl(i+1)=c(i+1)-c(i);
    end
end
cumpl=cumsum(pl);plot(cumpl)
