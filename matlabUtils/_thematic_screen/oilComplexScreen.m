%
%__________________________________________________________________________
%
% JGB Model -asset reallocation rationale
% - Nikkey trend & Volume 
% - AUDJPY
%__________________________________________________________________________
%
%
function screenOutput = oilComplexScreen(dataScreen)

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
    % Weekly return
    c5dr = Delta(c,'roc',5);
    % Oil 5th tenor
    co5 = dataScreen.factors(:,1);
    % build contango spread & moving averages
    co5co1 = co5 ./ c(:,3);
    mafco5co1 = expmav(co5co1, 3);
    masco5co1 = expmav(co5co1, 55);%
    % relative price
    cxlesp = c(:,1) ./ (1.5*c(:,2)); hxlesp = h(:,1) ./ (1.5*l(:,2)); lxlesp = l(:,1) ./ (1.5*h(:,2));
    ceqcom = cxlesp ./ (1* c(:,1)); heqcom = hxlesp ./ (1* l(:,1)); leqcom = lxlesp ./ (1* h(:,1));
    % -- Zscore 0f oscillator --
    % intrument level
    k = StochasticFunction(c,h,l,'za', 5, 3,3);%21
    zk = ZScore(k,'za',256,[-3,3],1);%55, 89, 100, 125, 200 ...all work ok
    % XLE - t0 - SP500
    kxlesp = StochasticFunction(cxlesp,hxlesp,lxlesp,'za', 5, 3,3);%21
    zkxlesp = ZScore(kxlesp,'za',21,[-3,3],1);%34
    % XLE/SP - to - CO
    keqcom = StochasticFunction(ceqcom,heqcom,leqcom,'za', 5, 3,3);%21
    zkeqcom = ZScore(keqcom,'za',13,[-3,3],1);%34    
       
%
%__________________________________________________________________________
% Set Dimension & Prelocation
% Dimensions---------------------------------------------------------------
[nsteps,ncols] = size(c);
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
enterShortSynt = zeros(nsteps,1);
MinIncShortSynt = zeros(nsteps,1);
enterLongSynt = zeros(nsteps,1);
MaxIncLongSynt = zeros(nsteps,1);
%
% -- Capital --
capital = 100000;
% -- Transaction cost --
beep = 0.0001;
TC=[10, 2, 5] * beep;
%
% Initialisiation
i=350;
% Compute hedge XLE / SP vs CO1
lagPeriod = 20;
b1 = regress(c5dr(i-lagPeriod :i,1),c5dr(i-lagPeriod :i,2));
if b1<0, b1=0.5; end
% build XLE/SP
xlesp = c5dr(:,1) - b1 * c5dr(:,2);
b2 = regress(xlesp(i-lagPeriod :i,1),c5dr(i-lagPeriod :i,3));
if b2<0, b2=0.5; end
% csynth = (c(:,1) ./ (b1*c(:,2))) ./ (b2*c(:,3));
% hsynth = (h(:,1) ./ (b1*l(:,2))) ./ (b2*c(:,3));
% lsynth = (l(:,1) ./ (b1*h(:,2))) ./ (b2*c(:,3));
% csynth1d = Delta(csynth,'d',1);
% stdcsynth1d = VolatilityFunction(csynth1d,'std', 100, 30, 10e10); 
% ksynth = StochasticFunction(csynth,hsynth,lsynth,'za', 21,3,3);
% zksynth = ZScore(ksynth,'za',21,[-3,3],1);
countTime = 0;

% Step 5.: Extract Trading Signal__________________________________________
for i = 350:nsteps %- 250

    sHold = zeros(1,3);    sInitiate = zeros(1,3);    wgtgross = zeros(1,3);
    
    % -- Market timing condition added to contango / backwardation --
    % .. Long XLE/SP Short CO ..
    mutualEntryConLong=0;
    %if zkxlesp(i) < -1 &&  zk(i,3) >= 1, mutualEntryConLong=1; end
    if (zk(i,1) <= -1 &&  zk(i,3) >= -1 ) 
        mutualEntryConLong=1;
    end
    % .. Short XLE/SP Long CO ..
    mutualEntryConShort=0;
    %if zkxlesp(i)> 0 &&  zk(i,3) < 0, mutualEntryConShort=1; end  
    if zk(i,1) >= 0 &&  zk(i,3) < 2  
        mutualEntryConShort=1;
    end    
    
    %-- Initiate position --
    % Long XLE/SP Short CO
    if mafco5co1(i) >  masco5co1(i) && mutualEntryConLong==1
        sInitiate(1,1) = 1;        sInitiate(1,2) = -1;       sInitiate(1,3) = -1;   
        countTime = 0; 
    end
    % Short XLE/SP Long CO 
    if  mafco5co1(i) <  masco5co1(i) && mutualEntryConShort==1
        sInitiate(1,1) = -1;       sInitiate(1,2) = 1;        sInitiate(1,3) = 1;  
        countTime = 0; 
    end 

    % -- Keep position within contango / backwardation --
    % Long XLE/SP Short CO
    if mafco5co1(i) >  masco5co1(i) 
        if countTime < 20 && zk(i,1) < 1.5
            sHold(1,1) = 1;        sHold(1,2) = -1;       sHold(1,3) = -1;
            wgtgross(1,1) = 1;     wgtgross(1,2) = b1;    wgtgross(1,3) = b2; 
            countTime = countTime+1;
        else
            sHold(1,1) = 0;        sHold(1,2) = 0;       sHold(1,3) = 0;
            wgtgross(1,1) = 0;     wgtgross(1,2) = 0;    wgtgross(1,3) = 0; 
            countTime = 0;            
        end
    % Short XLE/SP Long CO    
    elseif  mafco5co1(i) <  masco5co1(i) 
        if countTime < 20%  && zk(i,1) > -3
            sHold(1,1) = -1;       sHold(1,2) = 1;        sHold(1,3) = 1;
            wgtgross(1,1) = 1;     wgtgross(1,2) = b1;    wgtgross(1,3) = b2; 
        else
            sHold(1,1) = 0;        sHold(1,2) = 0;       sHold(1,3) = 0;
            wgtgross(1,1) = 0;     wgtgross(1,2) = 0;    wgtgross(1,3) = 0; 
            countTime = 0;            
        end            
    end        
          
    % -- Re-compute hedge ratio when signal changes --
    if sInitiate(1,1) ~= s(i-1,1) || countTime == 0
        % Compute hedge ration XLE vs SP
        % Compute hedge XLE / SP vs CO1
        lagPeriod = 10;
        b1 = regress(c5dr(i-lagPeriod+1 :i,1),c5dr(i-lagPeriod+1 :i,2));
        if b1< 0.7
            b1 = 0.7;
        elseif b1 > 2
            b1 = 2;
        end
        % build XLE/SP vs Oil
        lagPeriod1 = 10;
        xlesp = c5dr(:,1) - b1 * c5dr(:,2);
        b2 = regress(xlesp(i-lagPeriod1+1 :i,1),c5dr(i-lagPeriod1 +1:i,3));
        if b2  < 0.5,
            b2=0.5; 
        elseif b2  > 1.5
            b2=1.5; 
        end
        wgtgross(1,1) = 1;      wgtgross(1,2) = b1;     wgtgross(1,3) = b2; 
    end

    % -- Algo --
    for j=1:3
        
        % - Enter Short - zksynth(i)>1
        if  s(i-1,j) ~= -1 && sInitiate(1,j) == -1
            s(i,j)=-1   ;                                   % Signal 
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=wgtgross(1,j);                                     % Weights
            ExecP(i,j)=+p(i,j)*(1-TC(1,j));                 % Entry price - Short
            HoldPeriodShort(i,j) = 0;                       % Short Trade Duration
            MinIncShort(i,j)=c(i,j);                            % Minimum Price Incursion of Short Trade 
            %enterShortSynt(i) = csynth(i);
            %MinIncShortSynt(i) = csynth(i);
            % - Hold Short Position -
        elseif s(i-1,j) == -1 && sHold(1,j) == -1 
            s(i,j)=-1;                                       % Update Signal
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j)=wgt(i-1,j);                            % Update Weights
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodShort(i,j)=HoldPeriodShort(i-1,j)+1;  % Update Short Trade Duration
            MinIncShort(i,j)=min(c(i,j),MinIncShort(i-1,j));      % Update Minimum Price Incursion of Short Trade 
            %MinIncShortSynt(i)=min(csynth(i),MinIncShortSynt(i-1));
        %end
        
        % - Enter Long - zksynth(i)<-1 %
        elseif  s(i-1,j) ~= 1 && sInitiate(1,j) == 1
            s(i,j)=+1;                                      % Signal
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j)=wgtgross(1,j);                                     % Weights
            ExecP(i,j)=-p(i,j)*(1+TC(1,j));                 % Entry price - Long
            HoldPeriodLong(i,j)=0;                          % Long Trade Duration            
            MaxIncLong(i,j)=c(i,j);                             % Maximun Price Incursion of Long Trade
            %enterLongSynt(i) = csynth(i);
            %MaxIncLongSynt(i) = csynth(i);
            % - Hold Long Position -csynth(i) > MaxIncLongSynt(i-1) - 7 * stdcsynth1d(i)%
        elseif s(i-1,j) == 1 && sHold(1,j) == 1 
            s(i,j)=+1;                                      % Update Signal 
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j) = wgt(i-1,j);                          % UpdateWeights                  
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodLong(i,j)=HoldPeriodLong(i-1,j)+1;    % Update Holding Period            
            MaxIncLong(i,j)=max(c(i,j),MaxIncLong(i-1,j));        % Update Maximun Price Incursion of Long Trade
            %MaxIncLongSynt(i)=max(csynth(i),MaxIncLongSynt(i-1));  
        end    
       
    end
       
    % Profit
    for j=1:3
        [grossreturn_i , tcforec_i] = Compute_StockFuture_PL(i, j, c, p, ExecP, s, wgt, nb, TC);
        grossreturn(i,j) = grossreturn_i;   
        tcforec(i,j) = tcforec_i;
    end
end
%
% -- Compute Equity Curve for Portfolio --
[ptfec, ptfpl,cumulnetret, stratreturn, netret] = Compute_EquityCurve(c, grossreturn, tcforec);
%
% -- Export --
screenOutput.dateBench = dateBench;
screenOutput.dateNum = dateNum;
screenOutput.ptfec = ptfec;
screenOutput.ptfpl = ptfpl;
screenOutput.s = s;

