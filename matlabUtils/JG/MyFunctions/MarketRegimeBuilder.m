function[mkr,SumMkr] = MarketRegimeBuilder(method,factor)
%__________________________________________________________________________
%
% IDENTIFY MARKET REGIMES
% Input: 
%__________________________________________________________________________
%
% DIMENSION & PRELOCATE MATRIX---------------------------------------------
nsteps=size(factor,1); mkr=zeros(nsteps,1);
% 
% IDENTIFY MARKET REGIMES--------------------------------------------------
switch method

    case 'model1'
       
    % Total Number Of Market Regimes    
    NbMKR=8;    SumMkr=zeros(1,NbMKR);
    % Compute Indicator....................................................
    FMAfactor1=TrendSmoother(factor(:,1),'ema', 10);
    SMAfactor1=TrendSmoother(factor(:,1),'ema', 50);
    FMAfactor2=TrendSmoother(factor(:,2),'ema', 20);
    SMAfactor2=TrendSmoother(factor(:,2),'ema', 200);      
    % Main loop............................................................
    OptionMB=2;
    if OptionMB==1
        for i=1:nsteps
            if factor(:,2)>=20
                if FMAfactor1(i)>=SMAfactor1(i)
                    if FMAfactor2(i)<=SMAfactor2(i)
                        mkr(i)=1;
                    else
                        mkr(i)=2;
                    end
                else
                    if FMAfactor2(i)<=SMAfactor2(i)
                        mkr(i)=3;
                    else
                        mkr(i)=4;
                    end
                end
            else
                if FMAfactor1(i)>=SMAfactor1(i)
                    if FMAfactor2(i)<=SMAfactor2(i)
                        mkr(i)=5;
                    else
                        mkr(i)=6;
                    end
                else
                    if FMAfactor2(i)<=SMAfactor2(i)
                        mkr(i)=7;
                    else
                        mkr(i)=8;
                    end
                end        
            end
        end
    elseif OptionMB==2
        for i=1:nsteps
            % BULL MARKET
            if FMAfactor1(i)>=SMAfactor1(i)
                % FALLING VOLATILITY                
                if FMAfactor2(i)<=SMAfactor2(i)
                    mkr(i)=1;
                % RISING VOLATILITY                    
                else
                    mkr(i)=2;
                end
            % BEAR MARKET
            else
                % FALLING VOLATILITY
                if FMAfactor2(i)<=SMAfactor2(i)
                    mkr(i)=3;
                % RISING VOLATILITY
                else
                    mkr(i)=4;
                end
            end
        end        
    end
    % Identify Market Regimes Percentage Occurence.........................
    counter=0;
    for i=1:nsteps, if mkr(i)~=0, counter=counter+1;  end; end
    for i=1:nsteps
        for j=1:NbMKR, if mkr(i)==j,  SumMkr(1,j)=1+SumMkr(1,j);  end;  end
    end
    SumMkr=SumMkr/counter;

end
% CHART--------------------------------------------------------------------
%    subplot(1,2,1); plot(mkr)
%    subplot(1,2,2); bar(SumMkr)