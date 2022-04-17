%
%__________________________________________________________________________
%
% Function to Compute P&L of a FX spot with carry
% 
% DirectionQuote
% Direct quote:  -1 for XXX/USD
% Indirect quote: 1 for USD/XXX
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i] = PL_Spot_withCarry2(i, j, p, ExecP, ...
                                             s, wgt, nb, LocRateDaily, usdRateDaily, ...
                                             TC, method, DirectionQuoteRate)
 
                                         
    % Adjust transaction cost
    Ftc1=0;% Ftc1 = Factor when Trade Out
    Ftc2=0;% Ftc2 = Factor when Trade In
    Ftc3=0;% Ftc3 = Factor when Nb of shares is different for same signals

    if s(i)==0 && s(i-1)~=0 % Exit a trade
        Ftc1=1; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In 
    elseif s(i-2,j)==0 && s(i-1,j)~=0 % Enter a trade
        Ftc1=0; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In        
    elseif s(i-1,j)==s(i-2,j);
        Ftc1=0; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    %elseif s(i-2,j)~=0 && s(i-1,j)==0
    %    Ftc1=1; % Factor when Trade Out
    %    Ftc2=0; % Factor when Trade In
    elseif (s(i-2,j)==1 && s(i-1,j)==-1) || (s(i-2,j)==-1 && s(i-1,j)==1)
        Ftc1=1; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In       
    end   
    % -- Ftc3 for nb.-of-shares-based P&L --
    if s(i,j)~=s(i-1,j) || (s(i,j)==s(i-1,j) && nb(i,j)==nb(i-1,j))
        Ftc3=0;
    elseif (s(i,j)==s(i-1,j) && nb(i,j)~=nb(i-1,j)) 
        Ftc3=1;
    else
        Ftc3=0;
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

        case 'signal@close - trade@open' % use this one

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
                                    DirectionQuoteRate*(LocRateDaily(i-1,j)-1*usdRateDaily(i-1,j)));
                end
                %if 
                tcforec_i = Ftc1*TC(1,j)*abs(wgt(i-1,j)) + Ftc2*TC(1,j)*abs(wgt(i-0,j)) + ...
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
