function SmartTechAnalysis(o, h, l, c, dates, dateRange, trenfilter, TitleInstrument, indicator, paramIndic)

%dates=tdaynum;
%trenfilter = [2,40];
%indicator='macd';
%paramIndic = [6,19, 9,3,8,21];
paramstrg=' ';
for u=1:size(paramIndic,2),
    %paramstrg=strcat(' Parameters: ',num2str(paramIndic(u)),',');
    paramstrg=strcat(paramstrg,num2str(paramIndic(u)),',');
end
paramstrg=strcat(' Parameters:',paramstrg); 
TitleIndicator = strcat('Oscillator: ', indicator,' - ', paramstrg);
%TitleInstrument='Instrument & Trend Filter';
StartPoint = dateRange(1,1);%500;
EndPoint = dateRange(1,2);%650;

%__________________________________________________________________________
%
% Create a nice financial chart
% Input: 
% Only one instrument
%        - If operator enter OHLC for financial time series, need to enter
%          in this order: Open, High, Low, Close and Instrument Date.
%        - If operator enter just one input, usually the Close (Last), 
%          enter in this order: close, dates
%
% 2 instruments (generally the asset and a moving average, or P&L)
%        - If operator enter OHLC for financial time series, need to enter
%          in this order: Open, High, Low, Close and Instrument Date.
%        - If operator enter just one input, usually the Close (Last), enter
%          enter in this order: close, dates
%
% IMPORTANT NOTE FOR DATES
% dates are double under format "tdaynum". Dates comes from an excel
% spreadsheet and is dowloaded as follows with the function Uploadxxx..
%        [num, txt] = xlsread(strcat(dirname,filename),sheetname);
%        tday = txt(2:end, 1); 
%        tdaynum = datenum(tday, 'mm/dd/yyyy'); % convert to numeric format
%
%http://www.mathworks.com/matlabcentral/answers/94467-how-can-i-use-plotyy-with-financial-time-series-created-using-the-finanicial-toolbox-3-2-r2007a
        
%__________________________________________________________________________
%

    % -- Compute trend filter --
    if trenfilter(1,1) == 1
        instTrend = arithmav(c,trenfilter(1,2));      
    elseif trenfilter(1,1) == 2
        instTrend = expmav(c,trenfilter(1,2));      
    elseif trenfilter(1,1) == 3  
        instTrend= triangularmav(c, trenfilter(1,2));
    elseif trenfilter(1,1) == 4
        [instTrend, hpc] = RollingHPFilter(c, trenfilter(1,2), trenfilter(1,3));          
    end
    tsinstTrend = fints(dates, instTrend, {'TrendFilter'});
    tsinstTrend.freq='daily';    
    
    
    % -- Compute Indicator --
    switch indicator
        case 'macd'
            [macdg, macds, histo, fhisto, shisto, ~, ~] = MACDFunction(c,'with 0',paramIndic(1,1),paramIndic(1,2), paramIndic(1,3),[paramIndic(1,4),paramIndic(1,5)],paramIndic(1,6));           
            xIndic = [histo, fhisto];
            tsindic = fints(dates, xIndic, {'Histogramm', 'Histo_MA'});
            tsindic.freq='daily';
        case 'rsi'
            [rsi, rsima] = RSIFunction(c,paramIndic(1,1),paramIndic(1,2), paramIndic(1,3));   
            xIndic = [rsi, rsima];
            tsindic = fints(dates, xIndic, {'RSI', 'RSI_MA'});
            tsindic.freq='daily';            
        case 'lane_stochastic'
            [lsk,lsd,lssd] = StochasticFunction(c,h,l,'ama',parameters(1,1),parameters(1,2), parameters(1,3));  
            xIndic = [lsk,lsd];
            tsindic = fints(dates, xIndic, {'Stochastic', 'Fast Stochastic'});
            tsindic.freq='daily';               
        case 'stochastic_momentum_index'
            [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[paramIndic(1,1),paramIndic(1,2), paramIndic(1,3),paramIndic(1,4)]);     
        case 'adx'
            [pdi,mdi,adx] = ADXFunction(h,l,c,paramIndic(1,1));         
            xIndic = [pdi,mdi,adx];
            tsindic = fints(dates, xIndic, {'+/DI', '-/DI', 'ADX'});
            tsindic.freq='daily';                  
    end    
        
    % -- Create Financial time series for instrument --
    x=[h, l, c, o];
    tsobj = fints(dates, x, {'High', 'Low', 'Close', 'Open'});
    tsobj.freq='daily';

    % -- Simple plot for Instrument & Trend Filter --
    %subplot(2, 1, 1);
    %candle(tsobj(StartPoint:EndPoint))
    %highlow(tsobj(StartPoint:EndPoint));
    %title('IBM Stock Prices, 10/01/95-12/31/95');

    % -- Complex plot for Instrument & Trend Filter --
    %ax(1) = 
    subplot(2, 1, 1);
    %h1 = plot(ax(1), tsobj.dates, fts2mat(tsobj.Close),'b');
    %h1 =
    highlow(tsobj(StartPoint:EndPoint),'b');
    %ticks = get(ax(1), 'xtick');
    %set(ax(1), 'xlim',[tsobj.dates(StartPoint) tsobj.dates(EndPoint)], 'xtick', ticks);grid on;
    %datetick(ax(1),'x',1, 'keeplimits','keepticks');   
    hold on
    %h2 = 
    plot(tsinstTrend(StartPoint:EndPoint), 'r');
    %plot(ax(1), tsobj.dates(StartPoint:EndPoint), fts2mat(tsinstTrend.TrendFilter(StartPoint:EndPoint)), 'r');
    % -- This code if and only if you want to plot on 2 axis --
    %ax(2) = axes('Units',get(ax(1),'Units'), 'Position',get(ax(1),'Position'),'Parent',get(ax(1),'Parent'));
    %h2 = plot(ax(2), tsobj.dates(StartPoint:EndPoint), fts2mat(tsinstTrend.TrendFilter(StartPoint:EndPoint)), 'g--');
    %set(ax(2),'YAxisLocation','right','Color','none', 'XGrid','off','YGrid','off','Box','off');
    %set(ax(2), 'xlim',[tsobj.dates(StartPoint) tsobj.dates(EndPoint)], 'xtick', ticks);
    %set(ax(2), 'XtickLabel', []);
    %legend('Instrument');  
    title(TitleInstrument);
 
    % -- Plot for Oscillator Indicator --
    subplot(2, 1, 2);
    plot(tsindic(StartPoint:EndPoint));
    %title('MACD of IBM Close Stock Prices, 10/01/95-12/31/95');
    title(TitleIndicator);
    %datetick('x', 'mm/dd/yy');
