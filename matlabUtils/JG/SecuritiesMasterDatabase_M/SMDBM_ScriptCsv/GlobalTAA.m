%
%__________________________________________________________________________
%
% Matfile format for global rates
% note: this database is only used to built proff of the ocncept
%
%__________________________________________________________________________


clear all
clc
%format double
%
ConBbg = bloomberg;%(8194,'10.50.100.120') % too many connections, dun why, just need bloomberg and ok
StartDate = '1/1/1980'; % Start date
% -- Enter Today Date --
EndDate = '9/16/2014';
%
% -- Master Destination Path --
path = 'S:\00 Individuals\Joel\CSVFiles\';

% Dowload Bloomberg History
% Alternative: 'VWO US Equity'='EEm US Equity',
TickerList = {  'US1 Comdty', 'AGG US Equity', 'LQD US Equity', 'IPE US Equity', 'RX1 Comdty', ...
                'HYG US Equity', 'EMB US Equity', ...
                'VNQ US Equity', ...
                'SP1 Index', 'EEM US Equity', 'EFA US Equity', ...
                'DBC US Equity',  ...
                'JPEIGLBL Index', 'VIX Index', 'NAPMPMI Index', 'USGG10YR Curncy','USGG2YR Curncy', ...
                'DBLCIX Index', 'MXEA Index', 'NDUEEGF Index', 'IBOXHY Index', 'BCITCT Index'}; 
for i=1:length(TickerList)
    AssetKey = i;    TickerName = TickerList(AssetKey);
    data = GetBbgHist(ConBbg, TickerName, 0,0, StartDate, EndDate); % No VWAP and No VOlume For rates
    % Save data under a text format with dynamic name
    FromBbg2Text(path, data, AssetKey) % return a text file called 'rates123.txt.
end

