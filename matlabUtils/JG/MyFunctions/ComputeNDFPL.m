%
%__________________________________________________________________________
%
% Function to Compute P&L
% Two different solutions are suggested
% solution 1: it seems to be the most exact solution as when a NDF trade is
% unwound before expiry, one need to enter an opposite NDF trade with same
% expiry.
% solution 2: proxy
% note: the difference between both is not large.
% DirectionQuote
% -1 for XXX/USD
% 1 for USD/XXX
% see spreadsheet FX_NDF_Built_and_PLMethodo.xls
%
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i] = ComputeNDFPL(i, j, c, p, ExecP, ...
                                             s, wgt, FwdRoll_mult, FwdRoll, ...
                                             HoldLong, HoldShort, ...
                                             cc_loc_rate, cc_usd_rate, ...
                                             TC, method, DirectionQuote)
                                         
                                         
% step 1: update parameters for transaction cost
% Adjust transaction cost
    Ftc1=0;% Ftc1 = Factor when Trade Out
    Ftc2=0;% Ftc2 = Factor when Trade In
    Ftc3=0;% Ftc3 = Factor when Nb of shares is different for same signals

    if s(i-1,j)==s(i-2,j);
        Ftc1=0; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif s(i-2,j)==0 && s(i-1,j)~=0
        Ftc1=0; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    elseif s(i-2,j)~=0 && s(i-1,j)==0
        Ftc1=1; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif (s(i-2,j)==1 && s(i-1,j)==-1) || (s(i-2,j)==-1 && s(i-1,j)==1)
        Ftc1=1; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    end   
    % -- Ftc3 for weights-based equity curve --
    if s(i,j) ~= s(i-1,j) || (s(i,j) == s(i-1,j) && wgt(i,j) == wgt(i-1,j)) 
        Ftc3wgt = 0;
    elseif (s(i,j) == s(i-1,j) && wgt(i,j) ~= wgt(i-1,j)) 
        Ftc3wgt = 1;
    else
        Ftc3wgt = 0;
    end                                         
                                         
                                         
                                         
switch method
    %
    % Rebuild Forward when trade closed before expiry
    case {'fwdBased', 'FwdBased', 'forwardBased','ForwardBased', 'fb', 'FB'}
        if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
            % First Day of the trade (factors in Forward Price with the new executionm price)
            if s(i,j) ~= 0 && s(i,j) ~= s(i-1,j) && ExecP(i-1,j) ~= 0
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;
            % Roll the forward if needed
            elseif s(i,j) == s(i-1,j) && ExecP(i,j) ~= ExecP(i-1,j) % position has been rolled
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;
            % Exit Position Before Expiry Date - Need to unwind NDF 
            % note 1: we need to recompute the forward from now to end of
            % period (assuming being constant and equal to FwdRoll  == 22, 
            % i.e. 1month)
            % note 2: the return at this point must take into account the
            % return form the unwinding position
            elseif s(i,j) == 0 && s(i-1,j) ~=0
                % rebuilt NDF with transaction cost
                if s(i-1,j) == 1 
                    NbDays2Expiry = HoldLong(i-1,j) - FwdRoll_mult * FwdRoll ;
                elseif s(i-1,j) == -1 
                    NbDays2Expiry = HoldShort(i-1,j) - FwdRoll_mult * FwdRoll ;
                end
                rebuilt_ndf = c(i,j) * exp(DirectionQuote*(cc_loc_rate(i,j) - cc_usd_rate(i,j)) * NbDays2Expiry/360) * (1 - s(i-1,j)*TC(1,j));
                % return: return of the position + return of the position due to the roll of the forward
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * ((p(i,j) / rebuilt_ndf - 1) + (p(i,j) / p(i-1,j) - 1));
            % Hold Position
            else
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j) / p(i-1,j) - 1) ;            
            end
            tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3wgt*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
            %ec(i,j)=(1+grossreturn(i,j)-tcforec(i,j))*ec(i-1,j);
        else
            grossreturn_i = 0;  tcforec_i = 0;
        end
    %      
    % Sppot with carry          
    case {'Spot_with_carry','spot_with_carry', 'swc'}
        if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
            % First Day of the trade: factors in Forward Price
            if s(i,j) ~= 0 && s(i,j) ~= s(i-1,j) && ExecP(i-1,j) ~= 0
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;
            % Roll the forward if needed
            elseif s(i,j) == s(i-1,j) && ExecP(i,j) ~= ExecP(i-1,j) % position has been rolled
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) ;
            % No change
            else
                grossreturn_i = s(i-1,j) * wgt(i-1,j) * (p(i,j)/p(i-1,j)-1) ;
            end
            tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3wgt*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
            % add carry
            if s(i-1,j)==1
                discountLoc = 0.95; discountUs = 1.05; % penalize lending, increase borrow
            else
                discountLoc = 1.05; discountUs = 0.95; % penalize lending, increase borrow               
            end
            grossreturn_i = grossreturn_i + s(i-1,j) * DirectionQuote * (discountUs * cc_usd_rate(i,j) - discountLoc * cc_loc_rate(i,j)) /360; % legacy : AUDUSD = DirectionQuote is -1, USDJPY DirectionQuote is 1
            %ec(i,j)=(1+grossreturn(i,j)-tcforec(i,j))*ec(i-1,j);
        else
            grossreturn_i = 0; 
            tcforec_i = 0;
        end          
        
end