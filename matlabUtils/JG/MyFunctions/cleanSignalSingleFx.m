  
function [s_i, nb_i, wgt_i, ExecP_i, holdPeriodShort_i, minIncursionShort_i,...
          holdPeriodLong_i, maxIncursionLong_i ] = ...
          cleanSignalSingleFx(rowIdx, s, nb, wgt, ExecP, p, c, TC, holdPeriodShort, minIncursionShort, ...
          holdPeriodLong, maxIncursionLong, grossSignalShort,grossSignalLong, grossHoldShort,  grossHoldLong )

    s_i=0; wgt_i=0; nb_i=0; ExecP_i=0;holdPeriodShort_i=0; minIncursionShort_i=0;holdPeriodLong_i=0;maxIncursionLong_i=0;
    % - Short USD / Buy Local Ccy - 
    if  s(rowIdx-1) ~= -1 &&  grossSignalShort == -1
        s_i = -1;                                                      % Signal
        nb_i = 1;%capital/p(i,j);                                      % Compute Number of Shares
        wgt_i = 1;                                                     % Weights
        ExecP_i = +p(rowIdx)*(1-TC); % Sell Stock (note: Major difference here: work with Fwd FX)
        holdPeriodShort_i = 0;                                         % Holding Period - Short
        minIncursionShort_i = c(rowIdx);                               % Minimum Incursion Long 
    % - Hold Short USD / Buy Local Ccy - 
    elseif s(rowIdx-1) == -1  &&  grossHoldShort == -1
        s_i = -1;                                                      % update Signal
        nb_i = nb(rowIdx-1);                                           % update nb of shares
        wgt_i = wgt(rowIdx-1);                                         % update Weights       
        ExecP_i = ExecP(rowIdx-1);                                     % Keep Execution Price - Roll forward
        holdPeriodShort_i = holdPeriodShort(rowIdx-1)+1;               % update Holding Period - Short
        minIncursionShort_i = min([c(rowIdx), minIncursionShort(rowIdx-1)]);     % Update Minimum Incursion Long        
    % - Buy USD / Sell Local Ccy -  
    elseif s(rowIdx-1) ~= 1  && grossSignalLong == 1
        s_i = +1;                                                      % Signal
        nb_i = 1;%capital/p(i,j);                                      % Compute Number of Shares
        wgt_i = 1;                                                     % Weights
        ExecP_i = -p(rowIdx)*(1+TC);  % Buy Stock (note: Major difference here: work with Fwd FX)
        holdPeriodLong_i = 0;    % Holding Period - Long
        maxIncursionLong_i = c(rowIdx); % Maximum Incursion Long   
    % - Hold Buy USD / Sell Local Ccy - 
    elseif s(rowIdx-1) == 1  && grossHoldLong == 1
        s_i = +1;                                                      % update signal
        nb_i = nb(rowIdx-1);                                           % update nb of shares
        wgt_i = wgt(rowIdx-1);                                         % update Weights            
        ExecP_i = ExecP(rowIdx-1);                                     % Keep Execution Price - Roll forward
        holdPeriodLong_i = holdPeriodLong(rowIdx-1)+ 1;                % update Holding Period - Long            
        maxIncursionLong_i = max([c(rowIdx), maxIncursionLong(rowIdx-1)]);       % update Maximum Incursion Long   
    end 
    
end