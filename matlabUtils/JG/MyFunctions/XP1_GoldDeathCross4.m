%__________________________________________________________________________
%
% XP1 Gold / Death Cross Model
%
% Works simply on Triangular Moving average
% The XP1 has large High-Low bars that produce worng signals
% THe boule-smoothing seems to allow to solve this problem a bit
% Besides, due to the same problem, and although indicators work fine with
% the close, it seems better to compute the indicator on the True Price
% Tradind hours: 
% For XP1 Comb:  - signal @ close : 13;30
%                - trade  @ open  : 14:10 (same day)
% For XP1 PIT:  -  signal @ close : 13;30
%                - trade  @ open  : 06:50 (next day)
%__________________________________________________________________________
%
%

     
ComputeFactors = 1;
if ComputeFactors == 1
    % -- Fetch Data --
    clc
    clear all
    %path = 'S:\08 Trading\088 Quantitative Global Macro\0881 Global_Macro\08812 CrossAssets\equity\';
    path = 'S:\00 Individuals\Joel\equity\';
    FutureOrCash = 1;% 1 = Future  --  2 or other = Cash
    if FutureOrCash == 1     % XP1 Comb
        [tday, tdaynum, o,h,l,c] = UploadFuture(path, 'equ24', 'data');     
    elseif FutureOrCash == 2 % XP1 PIT
        [tday, tdaynum, o,h,l,c] = UploadFuture(path, 'equ25', 'data');  
    elseif FutureOrCash == 3 % Cash
        [tday, tdaynum, o,h,l,c] = UploadFuture(path, 'equ26', 'data');   
    end 
    % -- Trend --  
    tmaf = expmav(h, 5);
    tmas = expmav(c, 125);     
    MAcontrol=expmav(c,200);        
    % -- RSI & Momentum RSI --        
    %rsix = RSIFunction(c,3,3,20);
    %masrsix=expmav(rsix,13);    mafrsix=expmav(rsix,3);
    % -- Trend Strenght Index --
    [tsiatr, matsiatr] = TrendStrengthIndex(c,h,l, 'atr', [10,3]);   
    %[tsiwb, matsiwb] = TrendStrengthIndex(c,h,l, 'absdif', [32,5,3]);
    % -- Volatility --
    atr = ATRFunction(c,h,l,14,3);
    % -- Auto-correlation --
    r1d = Delta(c,'roc',1);
    vr1d = VolatilityFunction(r1d,'std', 100, 20, 10e10);
    %ac60r1d = autocorr(r1d, 60, 1);       maac60r1d  = expmav(ac60r1d,3);
    %ac120r1d = autocorr(r1d, 120, 1);     maac120r1d  = expmav(ac120r1d,3);
    % -- MACD Normal, Fast & Sell Set-up --
    %[macdg, macds, hist, fhist, shist, ~, ~] = MACDFunction(c,'with 0',12,26, 9,[3,8],21);
    %[macdgf, macdsf, histf, fhistf, shistf, ~, ~] = MACDFunction(c,'with 0',6,19, 9,[3,8],21);
    %[macdgs, macdss, hists, fhists, shists, ~, ~] = MACDFunction(c,'with 0',19,39, 9,[3,8],21);
    % -- Stochastic Momentum --
    [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[2,25,5,5]);
    % -- Lane Stochastic -- 
    [lsk,lsd,lssd] = StochasticFunction(c,h,l,'ama',13,3,3);
    % -- Directional Trend Index --16,5,3
    dti = DirectionalTrendIndex(h, l, [10,10]);  madti = expmav(dti,3);  
    %[pdi,mdi,adx] = ADXFunction(h,l,c,13); maadx = expmav(adx,10);
    [kend,kendpv] = MannKendallTs(c,'rolling',30,0.05);
    %[vrt,zvrt]=RollingVRTest(c,50,'hom');
    %[nrows,nc]=size(adx);
    %for i=1:nrows, if isnan(adx(i)),adx(i)=0; end; end
    %r1adx = Delta(adx,'dif',1);
    %maac60r1adx  = expmav(ac60r1adx,3); ma2ac60r1adx  = expmav(maac60r1adx,3);
    %ma3ac60r1adx  = expmav(ma2ac60r1adx,3); ma4ac60r1adx  = expmav(ma3ac60r1adx,9);
    % -- Divergence Indicator --
    % r1d = Delta(c,'dif',1); stdr1d = VolatilityFunction(r1d,'std', 40, 20, 10e10);
    % vr1d = stdr1d .* stdr1d; r10d = Delta(c,'dif',10); r40d = Delta(c,'dif',40);
    % divi = r10d .* r40d ./ (vr1d .* vr1d);
    
end
%__________________________________________________________________________
%
%__________________________________________________________________________
% Set Dimension & Prelocation
% Dimensions---------------------------------------------------------------
[nsteps,ncols]=size(c);
% -- Execution price (tomorrow open price) --
vwap = o; % special case for future database now
p = ChoseExecutionPrice(o,h,l,c,vwap, 'open', 0.7);
%
% Pre-locate matrix--------------------------------------------------------
% .. Portfolio volatility ..
ptfret=zeros(size(c,1),1);
volptf=zeros(size(c,1),1);
s=zeros(size(c));       % Signals
ExecP=zeros(size(c));   % Execution Prices
nb=zeros(size(c));      % Number of Shares
wgt=zeros(size(c));     % Weights
tottrancost=zeros(size(c));     
% .. Equity Curve ..
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c)); 
GeoEC=zeros(size(c)); 
HoldShort=zeros(size(c));       HoldLong=zeros(size(c));    % Holding Period
MaxIncLong=zeros(size(c));      MinIncShort=zeros(size(c)); % Maximum / Minimum Incursion for Long & Short
modeltype=zeros(nsteps,1);
capital=100000;                 % Capital
beep = 0.0001; TC=[4 * beep];   % Transaction cost-
GoLong=zeros(nsteps,1);         % Condition for long
%
GoLong=zeros(nsteps,1);

% Step 5.: Extract Trading Signal__________________________________________
for i = 70:nsteps %- 250
   
    
    % -- Algo --
    for j=1:1
        % - Enter Short - && c(i) < MAcontrol(i) 
        if  s(i-1,j) ~= -1 && h(i) < tmas(i) && kendpv(i) > 0.1 && kendpv(i) > 1*kendpv(i-1)  && smi(i) < smi(i-1) 
            s(i,j)=-1;                          % Signal
            nb(i,j)=1;%capital/p(i,j)           % Compute Number of Shares
            wgt(i,j)=1;                         % Weights
            ExecP(i,j)=+p(i,j)*(1-TC(1,j));     % Sell Stock
            HoldShort(i,j) = 0;                 % Short Trade Duration     
            MinIncShort(i,j) = c(i,j);          % Minimum Incursion for Short          
        % - Hold Short Position -
        elseif s(i-1,j) == -1 && c(i) < MinIncShort(i-1) + 3*atr(i) && c(i) > ExecP(i-1) - 5 * atr(i)%  && dti(i) < 0
            s(i,j)=-1;                          % Keep Signal
            nb(i,j)=nb(i-1,j);                  % Keep nb of shares
            wgt(i,j)=wgt(i-1,j);                % Weights      
            ExecP(i,j)=ExecP(i-1,j);            % Keep Execution Price
            HoldShort(i,j)=HoldShort(i-1,j)+1;  % Increment Trade Duration
            MinIncShort(i,j) = min(c(i,j),MinIncShort(i-1,j));          % Minimum Incursion for Short
        end
        % - Enter Long - 
        if s(i-1,j) ~= 1 && tmaf(i) > tmas(i) && smi(i) > smi(i-1) && kendpv(i) > 1*kendpv(i-1)   && 1==2
            modeltype(i) = 1;                   % model type      
            s(i,j)=+1;                          % Signal
            nb(i,j)=1;%capital/p(i,j);          % Compute Number of Shares
            wgt(i,j)=1;                         % Weights
            ExecP(i,j) = -p(i,j)*(1+TC(1,j));   % Entry price Buy Stock
            HoldLong(i,j) = 0;                  % Long Trade Duration            
            MaxIncLong(i,j) = c(i,j);           % Maximum Incursion for Long
        % - Hold Long Position -
        elseif s(i-1,j) == 1  && tmaf(i) > tmas(i)  && c(i) > MaxIncLong(i-1) - 2*atr(i) && c(i) < -ExecP(i-1) + 3*atr(i)
            modeltype(i) = 1;                   % modeltype
            s(i,j)=+1;                          % Keep Signal
            nb(i,j)=nb(i-1,j);                  % Keep nb of shares
            wgt(i,j) = wgt(i-1,j);              % Weights                 
            ExecP(i,j)=ExecP(i-1,j);            % Keep Execution Price
            HoldLong(i,j)=HoldLong(i-1,j)+1;    % Increment Trade Duration            
            MaxIncLong(i,j) = max(c(i,j),MaxIncLong(i-1,j));           % Maximum Incursion for Long
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
AnalyzePL = 1;
if AnalyzePL == 1
    [hplongavg, hpshortavg, swgtl, swgts] = AnalysePL3(c, s, wgt, HoldLong, HoldShort);
end
%
% -- Charts --
ctime = (1:1:nsteps)';
% Plot time sries
sbp(1)=subplot(1,2,1);
plotyy(ctime,stratreturn,  ctime , c); %datetick('x','dd-mm-yyyy');
title('Profit & Loss');grid on;
sbp(2)=subplot(1,2,2);
plot(ctime,swgts,ctime,swgtl); %datetick('x','dd-mm-yyyy');
title('Total Weigths for Long & Short');grid on;
%
% -- Export Output --
ConcatenateOutput=[s(nsteps-1,:)', s(nsteps,:)', wgt(nsteps,:)'];
jo=[ptfec,ptfpl];%for backtest
voltoday = power(252,0.5)*vr1d(nsteps); % last day volatility
recent1dr = r1d(nsteps-59:nsteps);% column vector ot recent 1-day returns