  
function [s_i, nb_i, wgt_i, ExecP_i, holdPeriodShort_i, minIncursionShort_i,...
          holdPeriodLong_i, maxIncursionLong_i ] = ...
          cleanSignalSingleFxAllj(rowIdx, s, nb, wgt, ExecP, p, c, TC, WgtEntry, holdPeriodShort, minIncursionShort, ...
          holdPeriodLong, maxIncursionLong, grossSignalShort,grossSignalLong, grossHoldShort,  grossHoldLong )

    ncols = size(s,2);
    s_i=zeros(1,ncols);
    wgt_i=zeros(1,ncols); 
    nb_i=zeros(1,ncols);
    ExecP_i=zeros(1,ncols);
    holdPeriodShort_i=zeros(1,ncols);
    minIncursionShort_i=zeros(1,ncols);
    holdPeriodLong_i=zeros(1,ncols);
    maxIncursionLong_i=zeros(1,ncols);

    for j=1:ncols
        % - Short USD / Buy Local Ccy - 
        if  s(rowIdx-1,j) ~= -1 &&  grossSignalShort(1,j) == -1
            s_i(1,j) = -1;                                                      % Signal
            nb_i(1,j) = 1;%capital/p(i,j);                                      % Compute Number of Shares
            wgt_i(1,j) = WgtEntry;                                                     % Weights
            ExecP_i(1,j) = +p(rowIdx,j)*(1-TC(1,j)); % Sell Stock (note: Major difference here: work with Fwd FX)
            holdPeriodShort_i(1,j) = 0;                                         % Holding Period - Short
            minIncursionShort_i(1,j) = c(rowIdx,j);                               % Minimum Incursion Long 
        % - Hold Short USD / Buy Local Ccy - 
        elseif s(rowIdx-1,j) == -1  &&  grossHoldShort(1,j) == -1
            s_i(1,j) = -1;                                                      % update Signal
            nb_i(1,j) = nb(rowIdx-1,j);                                           % update nb of shares
            wgt_i(1,j) = wgt(rowIdx-1,j);                                         % update Weights       
            ExecP_i(1,j) = ExecP(rowIdx-1,j);                                     % Keep Execution Price - Roll forward
            holdPeriodShort_i(1,j) = holdPeriodShort(rowIdx-1,j)+1;               % update Holding Period - Short
            minIncursionShort_i(1,j) = min([c(rowIdx,j), minIncursionShort(rowIdx-1,j)]);     % Update Minimum Incursion Long        
        % - Buy USD / Sell Local Ccy -  
        elseif s(rowIdx-1,j) ~= 1  && grossSignalLong(1,j) == 1
            s_i(1,j) = +1;                                                      % Signal
            nb_i(1,j) = 1;%capital/p(i,j);                                      % Compute Number of Shares
            wgt_i(1,j) = WgtEntry;                                                     % Weights
            ExecP_i(1,j) = -p(rowIdx,j)*(1+TC(1,j));  % Buy Stock (note: Major difference here: work with Fwd FX)
            holdPeriodLong_i(1,j) = 0;    % Holding Period - Long
            maxIncursionLong_i(1,j) = c(rowIdx,j); % Maximum Incursion Long   
        % - Hold Buy USD / Sell Local Ccy - 
        elseif s(rowIdx-1,j) == 1  && grossHoldLong(1,j) == 1
            s_i(1,j) = +1;                                                      % update signal
            nb_i(1,j) = nb(rowIdx-1,j);                                           % update nb of shares
            wgt_i(1,j) = wgt(rowIdx-1,j);                                         % update Weights            
            ExecP_i(1,j) = ExecP(rowIdx-1,j);                                     % Keep Execution Price - Roll forward
            holdPeriodLong_i(1,j) = holdPeriodLong(rowIdx-1,j)+ 1;                % update Holding Period - Long            
            maxIncursionLong_i(1,j) = max([c(rowIdx,j), maxIncursionLong(rowIdx-1,j)]);       % update Maximum Incursion Long   
        end 
     end   
end