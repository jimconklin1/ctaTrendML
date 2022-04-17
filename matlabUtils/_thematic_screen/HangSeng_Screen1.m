%
%__________________________________________________________________________
%
% Hang Seng Model with two factors:
% - HIBOR LIBOR
% - Variance risk Prermium
%__________________________________________________________________________
%
%
function screenOutput = HangSeng_Screen1(dataScreen)

if (~isdeployed)
    addpath 'H:\GIT\matlabUtils\JG\MyFunctions\';
    addpath 'H:\GIT\matlabUtils\JG\SecuritiesMasterDatabase_M\SMDBM_Functions\';
    addpath 'H:\GIT\matlabUtils\JG\PortfolioOptimization\';
    addpath 'H:\GIT\liquidPtf\script\';
    addpath 'H:\GIT\mtsrp\';
end

% -- Extract needed structure  --
instrumentsList = dataScreen.instrumentsList;
vwapVolumeOpInt = dataScreen.vwapVolumeOpInt;
factorsList = dataScreen.factorsList;
%instsNb = length(instrumentsList);
%factorsNb = length(factorsList);
dateBench = dataScreen.dateBench ;
dateNum = dataScreen.dateNum ;
%nsteps = size(dateBench,1);

% -- O,H,L,C, Volume, VWAP, Open Interest --
o = dataScreen.o;   h = dataScreen.h;
l = dataScreen.l;   c = dataScreen.c;
if vwapVolumeOpInt(1,1) == 1, vwap = dataScreen.vwap; end
if vwapVolumeOpInt(1,2) == 1, volu  = dataScreen.volu; end
if vwapVolumeOpInt(1,3) == 1, opint  = dataScreen.opint; end

% -- Factors --
% Liquidity
hibor = dataScreen.factors(:,1);
libor = dataScreen.factors(:,2);
hiblib = hibor - libor;
tsStart1 = StartFinder(hibor, 'znan');    tsStart2 = StartFinder(libor, 'znan');
maxstart = max(tsStart1,tsStart2);           hiblib(1:maxstart-1)=zeros(1,maxstart-1);
%zhiblib = ZScore(hiblib,'za',80,[-3,3],1) ;
% Variance risk premium
vhsi = dataScreen.factors(:,3);
c1dr = Delta(c(:,1),'roc',1);
vol1rd = 100*power(252,0.5)*VolatilityFunction(c1dr,'std', 30, 30, 10e10);   
vrp = vhsi - vol1rd;  % vrp
zvrp = ZScore(vrp,'za',50,[-3,3],1);% zscore vrp
vrppct = RollingPercentile(vrp, 256); % 1-year rolling percentile rank vrp  
    
% -- Price-based factors --    
%maf = arithmav(c,2); mas = arithmav(c,5);
atr3 = ATRFunction(c,h,l,3,5);    
%mafhiblib = expmav(hiblib,3); mashiblib = expmav(hiblib,34);
%
%
%__________________________________________________________________________
% Set Dimension & Prelocation
% Dimensions---------------------------------------------------------------
[nsteps,ncols]=size(c);
% -- Execution price (tomorrow open price) --
vwap = c; % special case for future database now
p = ChoseExecutionPrice(o,h,l,c,vwap, 'open', 0.7);
%
% Pre-locate matrix--------------------------------------------------------
% .. Portfolio volatility ..
ptfret=zeros(size(c,1),1);
volptf=zeros(size(c,1),1);
s=zeros(size(c));           % Signals
ExecP=zeros(size(c));       % Execution Prices
nb=zeros(size(c));          % Number of Shares
wgt=zeros(size(c));         % Weightts
tottrancost=zeros(size(c));     
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c)); 
GeoEC=zeros(size(c)); 
HoldPeriodLong=zeros(size(c));  % Holding Period Short
HoldPeriodShort=zeros(size(c)); % Holding Period Long
MaxIncLong=zeros(size(c));      % Maximun Price Incursion of Long Trade
MinIncShort=zeros(size(c));     % Minimum Price Incursion of Short Trade 
capital=100000;                 % Capital
beep = 0.0001; TC = 3 * beep;   % Transaction cost

% -- Backtest Screen --
for i = 200:nsteps %- 250

    %liqPush=0;
    if   hiblib(i) <= hiblib(i-20) || hiblib(i) <= hiblib(i-30) || ...
            hiblib(i) <= hiblib(i-40) %|| mafhiblib(i) <= mashiblib(i)
        liqPush = 1;
    else
            liqPush=0;
    end
    
    for j=1:ncols
        % - Enter Short - 
        if  s(i-1,j) ~= -1 && s(i-1,j) ~= 1 && (zvrp(i) <-1.5  || zvrp(i-1) <-1.5)  && liqPush==0  
            s(i,j)=-1   ;                                   % Signal 
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=1;                                     % Weights
            ExecP(i,j)=+p(i,j)*(1-TC(1,j));                 % Entry price - Short
            HoldPeriodShort(i,j) = 0;                       % Short Trade Duration
            MinIncShort(i)=c(i);                            % Minimum Price Incursion of Short Trade 
        % - Hold Short Position - 
        elseif s(i-1,j) == -1  && HoldPeriodShort(i-1,j) < 65 && c(i) > MinIncShort(i-1)+3*atr3(i)  
            s(i,j)=-1;                                       % Update Signal
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j)=wgt(i-1,j);                            % Update Weights
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodShort(i,j)=HoldPeriodShort(i-1,j)+1;  % Update Short Trade Duration
            MinIncShort(i)=min(c(i),MinIncShort(i-1));      % Update Minimum Price Incursion of Short Trade 
        %end
        
        % - Enter Long - 
        elseif  s(i-1,j) ~= 1  && zvrp(i) > 1 && liqPush==1  
            s(i,j)=+1;                                      % Signal
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=1;                                     % Weights
            ExecP(i,j)=-p(i,j)*(1+TC(1,j));                 % Entry price - Long
            HoldPeriodLong(i,j)=0;                          % Long Trade Duration            
            MaxIncLong(i)=c(i);                             % Maximun Price Incursion of Long Trade
        % - Hold Long Position -
        elseif s(i-1,j)==1  &&  HoldPeriodLong(i-1,j) < 65  && c(i) > MaxIncLong(i-1)-5*atr3(i)
            s(i,j)=+1;                                      % Update Signal 
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j) = wgt(i-1,j);                          % UpdateWeights                  
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodLong(i,j)=HoldPeriodLong(i-1,j)+1;    % Update Holding Period            
            MaxIncLong(i)=max(c(i),MaxIncLong(i-1));        % Update Maximun Price Incursion of Long Trade
        end    
    end
       
    % Profit
    for j=1:ncols
        [grossreturn_i , tcforec_i] = Compute_StockFuture_PL(i, j, c, p, ExecP, s, wgt, nb, TC);
        grossreturn(i,j) = grossreturn_i;   
        tcforec(i,j) = tcforec_i;
    end
end
%
% -- Compute Equity Curve for Portfolio --
[ptfec, ptfpl,cumulnetret, stratreturn, netret] = Compute_EquityCurve(c, grossreturn, tcforec);

% -- export --
screenOutput.dateBench = dateBench;
screenOutput.dateNum = dateNum;
screenOutput.ptfec = ptfec;
screenOutput.ptfpl = ptfpl;
screenOutput.s = s;

