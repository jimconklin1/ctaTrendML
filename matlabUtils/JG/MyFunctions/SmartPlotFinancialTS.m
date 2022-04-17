function SmartPlotFinancialTS(method, o, h, l, c, dates, y)

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

% -- assign --
if nargin == 3 
    % First time series
    x = o;
    tsobj = fints(dates, x, {'Close'});
    tsobj.freq='daily';
elseif nargin == 4
    % First time series    
    x = o;
    tsobj = fints(dates, x, {'Close'});
    tsobj.freq='daily';   
    % second time series
    tsobjy = fints(dates, y, {'ts2'});
    tsobjy.freq='daily';     
elseif nargin == 6 
    % First time series    
    % note: order must be High, Low, Close, Open
    x=[h, l, c, o];
    tsobj = fints(dates, x, {'High', 'Low', 'Close', 'Open'});
    tsobj.freq='daily';
elseif nargin == 7 
    % First time series    
    % note: order must be High, Low, Close, Open
    x=[h, l, c, o];
    tsobj = fints(dates, x, {'High', 'Low', 'Close', 'Open'});
    tsobj.freq='daily';   
    % wsecond time series    
    tsobjy = fints(dates, y, {'series1'});
    tsobjy.freq='daily'; 
else
    display('function "SmartPlotFinancialTS" does not have required number of argument')
end


switch method
    
    case 'ohlc' 
        
        candle(tsobj)
        Color  = 'b';
        title('Instrument OHLC')
        
    case 'ohlc_and_ts'
       
        %f = figure;
        
        cax = newplot;
        ax(1) = cax;
        h1 = plot(ax(1), tsobj.dates, fts2mat(tsobj.Close),'b');
        ticks = get(ax(1), 'xtick');
        set(ax(1), 'xlim',[tsobj.dates(1) tsobj.dates(end)], 'xtick', ticks);grid on;
        datetick(ax(1),'x',1, 'keeplimits','keepticks');   
        
        ax(2) = axes('Units',get(ax(1),'Units'), 'Position',get(ax(1),'Position'),'Parent',get(ax(1),'Parent'));
        h2 = plot(ax(2), tsobj.dates, fts2mat(tsobjy.series1), 'g--');
        set(ax(2),'YAxisLocation','right','Color','none', 'XGrid','off','YGrid','off','Box','off');
        set(ax(2), 'xlim',[tsobj.dates(1) tsobj.dates(end)], 'xtick', ticks);
        set(ax(2), 'XtickLabel', []);

        legend(ax(1), [h1 h2], 'Instrument', 'Indicator');        

end

