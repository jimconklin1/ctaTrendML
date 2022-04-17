%
%__________________________________________________________________________
%
% Compute Kalman Filter
% INputs:
% - matrix of close
% - delta - delta=1 gives fastest change in beta, delta=0.000....1 allows 
% no change (like traditional linear regression).
%__________________________________________________________________________
%

function [beta, yhat, Q, signal, positions, positions_carriedover] = kf2variables(c, delta, Ve, FactorQ)

    % -- Assign close --
    x = c(:, 1);        x(isnan(x))=0;
    y = c(:, 2);        y(isnan(y))=0;

    % -- Initialize beta(:, 1) to zero --
    beta(:,1) = 0;
    % -- Given initial beta and R (and P) --
    % Augment x with ones to  accomodate possible offset in the regression
    % between y vs x.
    x = [x ones(size(x))]; % note the one allows to compute the average spread, very useful then to extract signal
    %delta = 0.003; % delta=1 gives fastest change in beta, delta=0.000....1 allows no change (like traditional linear regression).
    yhat = NaN(size(y));                % measurement prediction
    e = NaN(size(y));                   % measurement prediction error
    Q = NaN(size(y));                   % measurement prediction error variance
    % -- For clarity, we denote R(t|t) by P(t) - Initialize R, P and beta. --
    R = zeros(2);
    P = zeros(2);
    beta = NaN(2, size(x, 1));
    Vw = delta / (1-delta)*eye(2);
    %Ve = 0.001;    
    
    % -- Initialize beta(:, 1) to zero --
    beta(:,1) = 0;
    % -- Given initial beta and R (and P) --
    for t = 1:length(y)
        if (t > 1)
            beta(:, t) = beta(:, t-1);         % state prediction. Equation 3.7
            R = P+Vw;                          % state covariance prediction. Equation 3.8
        end
        yhat(t) = x(t, :) * beta(:, t);        % measurement prediction. Equation 3.9
        Q(t) = x(t, :) * R * x(t, :)' + Ve;    % measurement variance prediction. Equation 3.10
        % Observe y(t)
        e(t) = y(t) - yhat(t);                 % measurement prediction error
        K = R*x(t, :)' / Q(t);                 % Kalman gain
        beta(:, t) = beta(:, t) + K * e(t);    % State update. Equation 3.11
        P = R-K*x(t, :) * R;                   % State covariance update. Euqation 3.12   
    end  
    
    % -- Extract signals --
    y2=[x(:, 1) y];                      % matrix of closing prices
    %FactorQ = 0.01;                       % factor applied to sqrt(Q)
    Threshold_entry = FactorQ * sqrt(Q); % Threshold to trigger trade
    % Buy inst1 / Short inst2
    longsEntry = e < -Threshold_entry;% a long position means we should buy inst1 / short inst2
    longsExit = e > -Threshold_entry; 
    % Short inst1 / Buy inst2
    shortsEntry = e > Threshold_entry;% a long position means we should short inst1 / buy inst2
    shortsExit = e < Threshold_entry;
    % Positions
    numUnitsLong=NaN(length(y2), 1);
    numUnitsShort=NaN(length(y2), 1);
    % Nb units long
    numUnitsLong(1)=0;
    numUnitsLong(longsEntry)=1; 
    numUnitsLong(longsExit)=0;
    numUnitsLong=fillMissingData(numUnitsLong); % It simply carry forward an existing position from previous day
                                                % if today's positio is an indeterminate NaN.
                                                            
    % Nb units short
    numUnitsShort(1)=0;
    numUnitsShort(shortsEntry)=-1; 
    numUnitsShort(shortsExit)=0;
    numUnitsShort=fillMissingData(numUnitsShort);
    
    % Total number of units
    numUnits = numUnitsLong + numUnitsShort;
    positions = repmat(numUnits, [1 size(y2, 2)]) .* [-beta(1, :)' ones(size(beta(1, :)'))] .* y2;
    % [hedgeRatio -ones(size(hedgeRatio))] is the shares allocation, [hedgeRatio -ones(size(hedgeRatio))].*y2 is the dollar capital allocation, while positions is the dollar capital in each ETF.
    
    % Keep positions constant is same consecutive signs
    positions_carriedover = positions;
    for i=2:size(positions)
        for j=1:2
            if sign(positions_carriedover(i,j)) == sign(positions_carriedover (i-1,j)) 
                positions_carriedover(i,j) = positions_carriedover (i-1,j);
            end
        end
    end
    signal = sign(positions); % create a matrix of signals   
    
    % transpose
    beta = beta';    
    
    positions_trade = positions_carriedover;                       
    
%     pnl = sum(lag(positions_trade, 1).*(y2-lag(y2, 1))./lag(y2, 1), 2);    % daily P&L of the strategy
%     carry = 0;%sum(lag(positions_trade, 1) .* (lag(intersect_locrate_daily,1)-lag(intersect_usdrate_daily,1)), 2); % carry component
%     pnl_with_carry = pnl + carry;
%     ret = pnl./sum(abs(lag(positions_trade, 1)), 2); % return is P&L divided by gross market value of portfolio without carry
%     ret_with_carry = ret;%pnl_with_carry./sum(abs(lag(positions_trade, 1)), 2); % return is P&L divided by gross market value of portfolio without carry
%     ret(isnan(ret)) = 0;
%     ret_with_carry(isnan(ret_with_carry)) = 0;
%     cumulPL = cumprod(1+ret)-1; 
%     cumulPL_with_carry = cumprod(1+ret_with_carry)-1; 
%     figure;
%     plot((1:1:size(cumulPL,1))', cumulPL, (1:1:size(cumulPL,1))', cumulPL_with_carry); % Cumulative compounded return
%     title('Cumulated P&L with & without carry');
%     fprintf(1, 'APR wihtout carry =%f Sharpe=%f\n', prod(1+ret).^(252/length(ret))-1, sqrt(252)*mean(ret)/std(ret));
%     fprintf(1, 'APR with carry =%f Sharpe=%f\n', prod(1+ret_with_carry).^(252/length(ret_with_carry))-1, sqrt(252)*mean(ret_with_carry)/std(ret_with_carry));    