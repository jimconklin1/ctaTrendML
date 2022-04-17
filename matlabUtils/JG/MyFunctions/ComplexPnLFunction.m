function [grossreturn, tcforec] = ComplexPnLFunction(c, o, signal_trade, wgt_trade)

%__________________________________________________________________________
%
% Complex P&L function
% joel guglietta - June 2014
%__________________________________________________________________________
%

clear s
clear p

%__________________________________________________________________________
% Set Dimension & Prelocation
% Dimensions---------------------------------------------------------------
[nsteps,ncols]=size(c);
% -- Execution price (tomorrow open price) --
vwap = o; % special case for future database now
p = c;%ChoseExecutionPrice(o,h,l,c,vwap, 'open', 0.7);
%
% Pre-locate matrix--------------------------------------------------------
% .. Portfolio volatility ..
ptfret=zeros(size(c,1),1);
volptf=zeros(size(c,1),1);
% .. Signals ..
s=zeros(size(c));
% .. Execution Prices ..
ExecP=zeros(size(c));  
% .. Number of Shares ..
nb=zeros(size(c));
% .. Weightts ..
wgt=zeros(size(c));    
% .. Profit ..
%profit=zeros(size(c));          sumprofit=zeros(size(c));
%grossprofit=zeros(size(c));     sumgrossprofit=zeros(size(c));
tottrancost=zeros(size(c));     
% .. Equity Curve ..
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c)); 
GeoEC=zeros(size(c)); 
% -- Holding Period --
HoldShort=zeros(size(c));       HoldLong=zeros(size(c));  
modeltype=zeros(nsteps,1);
% --  Update Minimum Short & Maximum Long --
MinShort= zeros(nsteps,1);  MaxLong = zeros(nsteps,1);
%
% -- Capital --
capital=100000;
% -- Transaction cost --
beep = 0.0001; TC=[0 * beep];

%
GoLong=zeros(nsteps,1);
%

% -- Number to exclude for the in-sample test --
Outside_InSample = 0;

start_trading=3500;

% Step 5.: Extract Trading Signal__________________________________________
for i = start_trading-start_trading + 3 : nsteps  - Outside_InSample
    
    %  
    % Equity
    for j=1:1
        % ---- Short Leg ---- 
        % - Enter Short - 
        if  s(i-1,j) ~= -1 && signal_trade(i,j) == -1 %&& zrsix(i) > 0% mascl(i)%kendpv(i) > 0.001%zScore(i)>0
            % Re-initilaise FwdRoll Multiple
            %FwdRoll_mult = 1;            
            % Signal
            s(i,j)=-1;  
            % Compute Number of Shares
            nb(i,j) = 1;%capital/p(i,j); 
            % Weights
            wgt(i,j) =  abs(wgt_trade(i,j));
            % Sell Stock (note: Major difference here: work with Fwd FX)
            ExecP(i,j) = +p(i,j)*(1-TC(1,j)); 
            % Short Trade Duration
            HoldShort(i,j) = 0;      
            % Minimum reached
            MinShort(i) = c(i,j);            
        % - Hold Short Position - note: MoAvg. & ATR based
        elseif s(i-1,j) == -1 && signal_trade(i,j) == -1
            % Keep Signal
            s(i,j) = -1;  
            % Keep nb of shares
            nb(i,j) = nb(i-1,j);
            % Weights
            %wgt(i,j) = abs(wgt_trade(i,j));                     
            wgt(i,j) = wgt(i-1,j);           
            % Keep Execution Price - Roll forward
            %if HoldShort(i-1,j) < FwdRoll_mult * FwdRoll  
                ExecP(i,j) = ExecP(i-1,j);  
            %else
            %    ExecP(i,j) = cfwd(i,j)*(1-TC(1,j));
            %    FwdRoll_mult = FwdRoll_mult + 1;
            %end
            % Increment Trade Duration
            HoldShort(i,j) = HoldShort(i-1,j)+1;  
            % Update Minimum Short
            MinShort(i) = min([c(i,j), MinShort(i-1,j)]);           
        end
        % ---- Long Leg ----  
        % - Enter Long - 
        if s(i-1,j) ~= 1 && signal_trade(i,j) == 1 %&& zrsix(i) < 0%mafcl(i) > mascl(i)%0.001% && zScore(i)<0
            % Re-initilaise FwdRoll Multiple
            %FwdRoll_mult = 1;            
            % Signal
            s(i,j)=+1;  
            % Compute Number of Shares
            nb(i,j)=1;%capital/p(i,j);  
            % Weights
            wgt(i,j) =   abs(wgt_trade(i,j));
            % Buy Stock (note: Major difference here: work with Fwd FX)
            ExecP(i,j) = -p(i,j)*(1+TC(1,j));  
            % Long Trade Duration            
            HoldLong(i,j) = 0;   
            % Maximum Long
            MaxLong(i) = c(i,j);            
        % - Hold Long Position - 
        elseif s(i-1,j) == 1 && signal_trade(i,j) == 1
            % Keep Signal
            s(i,j) = +1;
            % Keep nb of shares
            nb(i,j) = nb(i-1,j);        
            % Weights
            %wgt(i,j) = abs(wgt_trade(i,j));                    
            wgt(i,j) = wgt(i-1,j); 
            % Keep Execution Price - Roll forward
            %if HoldShort(i-1,j) <  FwdRoll_mult * FwdRoll  
                ExecP(i,j) = ExecP(i-1,j); 
            %else
            %    ExecP(i,j) = -cfwd(i,j)*(1+TC(1,j)); 
            %    FwdRoll_mult = FwdRoll_mult + 1;
            %end
            % Increment Trade Duration            
            HoldLong(i,j) = HoldLong(i-1,j)+ 1;      
            % Update Maximum Long
            MaxLong(i) = max([c(i,j), MaxLong(i-1)]);             
        end  
    end
       
    % Profit
    for j=1:1
        [grossreturn_i , tcforec_i] = Compute_StockFuture_PL(i, j, c, p, ExecP, s, wgt, nb, TC);
        grossreturn(i,j) = grossreturn_i;   
        tcforec(i,j) = tcforec_i;
    end
    
end
%
