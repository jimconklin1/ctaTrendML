%
%__________________________________________________________________________
%
% Run Strategy tester
% Use Parallel Computing with the "parfor" loop
%__________________________________________________________________________
%

% -- Prelocate Matrix --

%
% -- Load Price Time Series(Bbg download - Shared Drive) --
maindrive='S:\';
dir1='08 Trading\';  
dir2='088 Quantitative Global Macro\';     
dir3='0881 CrossAssets\development\';
dirname=strcat(maindrive,dir1,dir2,dir3);
% fetch Data
[num, txt]=xlsread(strcat(dirname,'Turtle_Value.xls'),'data');
o=num(:,1);h=num(:,2);l=num(:,3);c=num(:,4);
% -- Load Parameters for Models (Workstation) --
maindrive='C::\';
dir1='JG\';  
dir2='Quantitative_Global_Macro\';     
dir3='QGM1_CrossAssets\QGM10_CrossAssets_Current\';
dirname=strcat(maindrive,dir1,dir2,dir3);
% Fetch Parameters
XlsParameters=xlsread(strcat(dirname,'Turtle_Value.xls'),'parameters');

% -- Clean --
for i=2:length(c), 
    if o(i)==0, o(i)=c(i-1); end
end
for i=2:length(c),
    if h(i)==0, h(i)=c(i-1); end 
end
for i=2:length(c),
    if h(i)==0, h(i)=c(i-1); end
end
%
% Format time
tday=txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
tday=datestr(datenum(tday, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
tday=str2double(cellstr(tday)); % convert the date strings first into cell arrays and then into numeric format.
%
% Assign parameters
MaType=XlsParameters(1,1);if MaType==1, MaType='e'; elseif MaType==2, MaType='a'; end
Modele=XlsParameters(2,1);
DualMAPar=XlsParameters(17:20);
TripleMAPar=XlsParameters(25:29);
DonchianMAPar=XlsParameters(34:41);
BollMAParam=XlsParameters(46:51);
ATRMAParam=XlsParameters(57:62);

if Modele==1
    % Dual Moving Average system
    maf = TrendSmoother(c, MaType, DualMAPar(1,1));
    mas = TrendSmoother(c, MaType, DualMAPar(2,1));
    [s, sumprofit, sumgrossprofit]  =  DualMASyst(o, h, l, c, maf, mas);    
elseif Model==2
    % Dual Moving Average system + Time-based Exit Rule
    maf = TrendSmoother(c, MaType, DualMAPar(1,1));
    mas = TrendSmoother(c, MaType, DualMAPar(2,1));
    MaxHPShort=DualMAPar(3,1);
    MaxHPLong=DualMAPar(4,1);
    [s, sumprofit, sumgrossprofit]  =  DualMATimeSyst(o, h, l, c, maf, mas, MaxHPShort, MaxHPLong);
elseif Modele==3
    % Triple Moving Average System
    maf = TrendSmoother(c, MaType, TripleMAPar(1,1));
    mas = TrendSmoother(c, MaType, TripleMAPar(2,1));
    mavs = TrendSmoother(c, MaType, TripleMAPar(3,1));
    [s, sumprofit, sumgrossprofit]  =  TripleMASyst(o, h, l, c, maf, mas, mavs);
elseif Modele==4
    % Triple Moving Average System + Time-based Exit Rule
    maf = TrendSmoother(c, MaType, TripleMAPar(1,1));
    mas = TrendSmoother(c, MaType, TripleMAPar(2,1));
    mavs = TrendSmoother(c, MaType, TripleMAPar(3,1));
    MaxHPShort=TripleMAPar(4,1);
    MaxHPLong=TripleMAPar(5,1);    
    [s, sumprofit, sumgrossprofit]  =  TripleMATimeSyst(o, h, l, c, maf, mas, mavs,  MaxHPShort, MaxHPLong)  ;
elseif Modele==5
    % Donchian
    Lookback=zeros(4,1);
    Lookback(1,1)=DonchianMAPar(3,1);    Lookback(1,2)=DonchianMAPar(4,1); % Long In & Out
    Lookback(1,1)=DonchianMAPar(5,1);    Lookback(1,2)=DonchianMAPar(6,1); % Short In & Out
    [s, sumprofit, sumgrossprofit]  =  Donchian(o, h, l, c, Lookback);
elseif Modele==6
    % Donchian + Time-based Exit Rule
    Lookback=zeros(4,1);
    Lookback(1,1)=DonchianMAPar(3,1);    Lookback(1,2)=DonchianMAPar(4,1); % Long In & Out
    Lookback(1,1)=DonchianMAPar(5,1);    Lookback(1,2)=DonchianMAPar(6,1); % Short In & Out 
elseif Modele==7
    % Donchian + Moving Average Filter
    Lookback=zeros(4,1);
    Lookback(1,1)=DonchianMAPar(3,1);    Lookback(1,2)=DonchianMAPar(4,1); % Long In & Out
    Lookback(1,1)=DonchianMAPar(5,1);    Lookback(1,2)=DonchianMAPar(6,1); % Short In & Out  
    maf = TrendSmoother(c, MaType, DonchianMAPar(1,1));
    mas = TrendSmoother(c, MaType, DonchianMAPar(2,1));
    [s, sumprofit, sumgrossprofit]  =  DonchianFilterSyst(o, h, l, c, Lookback, maf, mas);
elseif Modele==8
    % Donchian + Moving Average Filter + Time-based Exit Rule
    Lookback=zeros(4,1);
    Lookback(1,1)=DonchianMAPar(3,1);    Lookback(1,2)=DonchianMAPar(4,1); % Long In & Out
    Lookback(1,1)=DonchianMAPar(5,1);    Lookback(1,2)=DonchianMAPar(6,1); % Short In & Out  
    maf = TrendSmoother(c, MaType, DonchianMAPar(1,1));
    mas = TrendSmoother(c, MaType, DonchianMAPar(2,1));
    MaxHPShort=DonchianMAPar(7,1);
    MaxHPLong=DonchianMAPar(8,1);       
    [s, sumprofit, sumgrossprofit]  =  DonchianFilterTimeSyst(o, h, l, c, Lookback, maf, mas, MaxHPShort, MaxHPLong);
elseif Modele==9  
    % Bollinger Breakout
    BollingerParameters(1,1)=MaType;
    BollingerParameters(1,2)=BollMAParam(1,1);
    BollingerParameters(1,3)=BollMAParam(2,1);
    BollingerParameters(1,4)=BollMAParam(3,1);
    BollingerParameters(1,5)=BollMAParam(4,1);
    [s, sumprofit, sumgrossprofit]  =  BollingerBreakoutSyst(o, h, l, c, BollingerParameters);
elseif Modele==10
    % Bollinger Breakout + Time-based Exit Rule
    BollingerParameters(1,1)=MaType;
    BollingerParameters(1,2)=BollMAParam(1,1);
    BollingerParameters(1,3)=BollMAParam(2,1);
    BollingerParameters(1,4)=BollMAParam(3,1);
    BollingerParameters(1,5)=BollMAParam(4,1);
    MaxHPShort=BollMAParam(5,1);
    MaxHPLong=BollMAParam(6,1);
    [s, sumprofit, sumgrossprofit]  =  BollingerBreakoutTimeSyst(o, h, l, c, BollingerParameters, MaxHPShort, MaxHPLong);  
elseif Modele==11  
    % ATR Breakout
    ma = TrendSmoother(c, MaType, ATRMAParam(1,1));
    ATRParameters(1,1)=ATRMAParam(2,1);
    ATRParameters(1,2)=ATRMAParam(3,1);
    ATRParameters(1,3)=ATRMAParam(4,1);
    [s, sumprofit, sumgrossprofit]  =  ATRBreakoutSyst(o, h, l, c,ATRParameters, ma);
elseif Modele==12
    % ATR Breakout + Time-based Exit Rule    
    ma = TrendSmoother(c, MaType, ATRMAParam(1,1));
    ATRParameters(1,1)=ATRMAParam(2,1);
    ATRParameters(1,2)=ATRMAParam(3,1);
    ATRParameters(1,3)=ATRMAParam(4,1);
    [s, sumprofit, sumgrossprofit]  =  ATRBreakoutSyst(o, h, l, c,ATRParameters, ma);
    MaxHPShort=ATRMAParam(5,1);
    MaxHPLong=ATRMAParam(6,1);
end
    
    

