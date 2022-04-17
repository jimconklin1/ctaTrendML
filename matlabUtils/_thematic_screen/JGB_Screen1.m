%
%__________________________________________________________________________
%
% JGB Model -asset reallocation rationale
% - Nikkey trend & Volume 
% - AUDJPY
%__________________________________________________________________________
%
%
function screenOutput = JGB_Screen1(dataScreen)

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
ni1 = dataScreen.factors(:,1);
%vnky = dataScreen.factors(:,2);
ccy = dataScreen.factors(:,3);
volni1 = dataScreen.factors(:,4);
% -- Compute indicators --
tlni = triangularmav(ni1,55);
%ni1dr = Delta(ni1,'roc',1);
%vol1rd = 100*power(252,0.5)*VolatilityFunction(ni1dr,'std', 30, 30, 10e10);   
%vrp = vnky - vol1rd ;
%zvrp = ZScore(vrp,'za',80,[-3,3],1);    
zccy = ZScore(ccy,'za',10,[-3,3],1) ; 
    
% -- Price-based factors --
%tl = triangularmav(c,100);
atr = ATRFunction(c,h,l,4,5);

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
%
% -- Capital --
capital=100000;
% -- Transaction cost --
beep = 0.0001;
TC = 3 * beep;

% Extract Trading Signal___________________________________________________
for i = 3500:nsteps %- 250

    % -- Algo --zccy(i) > 1
    for j=1:1
        % - Enter Short - zccy(i) > 1
        if  s(i-1,j) ~= -1  &&  ni1(i) > tlni(i) && volni1(i) > volni1(i-25)  && zccy(i) > 2 %&& maf(i) >  mas(i) && maf(i-1) < mas(i-1) %&& vnky(i) < vnky(i-3)%c(i) < h(i-5)%&& fmh(i) < max(fmh(i-50:i-1) ) 
            s(i,j)=-1   ;                                   % Signal 
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=1;                                     % Weights
            ExecP(i,j)=+p(i,j)*(1-TC(1,j));                 % Entry price - Short
            HoldPeriodShort(i,j) = 0;                       % Short Trade Duration
            MinIncShort(i)=c(i);                            % Minimum Price Incursion of Short Trade 
        % - Hold Short Position -.5
        elseif s(i-1,j) == -1  &&  HoldPeriodShort(i-1,j) < 10 && c(i) < MinIncShort(i-1,j) + 2 *atr(i) &&  c(i) > ExecP(i-1,j) - 2 * atr(i)
            s(i,j)=-1;                                       % Update Signal
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j)=wgt(i-1,j);                            % Update Weights
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodShort(i,j)=HoldPeriodShort(i-1,j)+1;  % Update Short Trade Duration
            MinIncShort(i)=min(c(i),MinIncShort(i-1));      % Update Minimum Price Incursion of Short Trade 
        %end
        
        % - Enter Long - zccy(i) < -1.8 
        elseif  s(i-1,j) ~= 1 && s(i-1,j) ~= -1  && zccy(i) < -1  && ni1(i) < tlni(i)% && volni1(i) < 1 *volni1(i-25) 
            s(i,j)=+1;                                      % Signal
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=1;                                     % Weights
            ExecP(i,j)=-p(i,j)*(1+TC(1,j));                 % Entry price - Long
            HoldPeriodLong(i,j)=0;                          % Long Trade Duration            
            MaxIncLong(i)=c(i);                             % Maximun Price Incursion of Long Trade
        % - Hold Long Position 
        elseif s(i-1,j)==1   && c(i) > MaxIncLong(i-1) - 9 *atr(i) &&  c(i) < -ExecP(i-1,j) + 15 * atr(i)
            s(i,j)=+1;                                      % Update Signal 
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j) = wgt(i-1,j);                          % UpdateWeights                  
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodLong(i,j)=HoldPeriodLong(i-1,j)+1;    % Update Holding Period            
            MaxIncLong(i)=max(c(i),MaxIncLong(i-1));        % Update Maximun Price Incursion of Long Trade
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
% -- Compute Equity Curve for Portfolio --
[ptfec, ptfpl,cumulnetret, stratreturn, netret] = Compute_EquityCurve(c, grossreturn, tcforec);
%
% -- Analyse P&L --
% AnalyzePL = 1;
% if AnalyzePL == 1
%     [hplongavg, hpshortavg, swgtl, swgts] = AnalysePL3(c, s, wgt, HoldLong, HoldShort);
% end
%
% -- Charts --
% StartingTime=3000;
%   plotyy(dateNum(StartingTime:end), c(StartingTime:end),...
%     dateNum(StartingTime:end), ptfec(StartingTime:end)); %datetick('x','mm/dd/yy')
% title('Profit & Loss');grid on;

%
% -- Export --
screenOutput.dateBench = dateBench;
screenOutput.dateNum = dateNum;
screenOutput.ptfec = ptfec;
screenOutput.ptfpl = ptfpl;
screenOutput.s = s;

