%
%__________________________________________________________________________
%
% Function to Compute P&L of a FX spot with carry
% 
% DirectionQuote
% -1 for XXX/USD
% 1 for USD/XXX
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i] = PL_Spot_withCarry(i, j, p, ExecP, ...
                                             s, wgt, LocRateDaily, usdRateDaily, ...
                                             Ftc1, Ftc2, Ftc3wgt, TC, method, DirectionQuoteRate)
  
switch method
    
    case 'signal@close - trade@open'
                                         
        if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
            % First Day of the trade: factors in Forward Price wgt(i-1,j)
            if s(i,j) ~= 0 && s(i,j) ~= s(i-1,j) && ExecP(i-1,j) ~= 0
                grossreturn_i = wgt(i-1,j) * s(i-1,j) * ( p(i,j)/abs(ExecP(i-1,j)) - 1 + ...
                                                          DirectionQuoteRate*(LocRateDaily(i-1,j)-usdRateDaily(i-1,j)));
            % Roll the forward if needed
            %elseif s(i,j) == s(i-1,j) && ExecP(i,j) ~= ExecP(i-1,j) % position has been rolled
            %    grossreturn_i = wgt(i-1,j) * (s(i-1,j) * (p(i,j)/abs(ExecP(i-1,j)) - 1) + ...
            %                                  s(i-1,j) * (LocRateDaily(i-1,j)-usdRateDaily(i-1,j)));
            % No change
            else
                grossreturn_i = wgt(i-1,j) * s(i-1,j) * ( p(i,j)/p(i-1,j) - 1 + ...
                                                          DirectionQuoteRate*(LocRateDaily(i-1,j)-0*usdRateDaily(i-1,j)));
            end
            tcforec_i = Ftc1*TC(1,j)*abs(wgt(i-2,j)) + Ftc2*TC(1,j)*abs(wgt(i-1,j)) + ...
                        Ftc3wgt*TC(1,j)*abs(abs(wgt(i-1,j))-abs(wgt(i-2,j))); % wgt or nb
            %ec(i,j)=(1+grossreturn(i,j)-tcforec(i,j))*ec(i-1,j);
        else
            grossreturn_i = 0; 
            tcforec_i = 0;
        end           
        
    case 'signal@close - trade@close'
                                         
        if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
            grossreturn_i = wgt(i-1,j) * s(i-1,j) * ( p(i,j)/p(i-1,j)-1 + ...
                                                      DirectionQuoteRate*(LocRateDaily(i-1,j)-usdRateDaily(i-1,j)));
            tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + ...
                        Ftc3wgt*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
            %ec(i,j)=(1+grossreturn(i,j)-tcforec(i,j))*ec(i-1,j);
        else
            grossreturn_i = 0; 
            tcforec_i = 0;
        end     
        
end        
        
        
        