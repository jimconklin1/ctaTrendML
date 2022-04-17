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
EndDate = '9/29/2014';
%
% -- Master Destination Path --
path = 'S:\00 Individuals\Joel\CSVFiles\BalancedRiskFund\';

% Dowload Bloomberg History
% Alternative: 'VWO US Equity'='EEm US Equity',
TickerList = {  'SP1 Index', 'VG1 Index', 'Z 1 Index', 'NI1 Index', 'XP1 Index', 'HI1 Index', 'KM1 Index',...
                'US1 Comdty', 'RX1 Comdty', 'CN1 Comdty','G 1 Comdty','JB1 Comdty', 'XM1 Comdty',...
                'XAU Curncy', 'XAG Curncy', 'CL1 Comdty', 'HG1 Comdty', 'S 1 Comdty','W 1 Comdty',...
                'VIX Index', 'USGG10YR Curncy','USGG2YR Curncy', 'US0003 Index'}; 
for i=1:length(TickerList)
    AssetKey = i;    TickerName = TickerList(AssetKey);
    data = GetBbgHist(ConBbg, TickerName, 0,0, StartDate, EndDate); % No VWAP and No VOlume For rates
    % Save data under a text format with dynamic name
    FromBbg2Text(path, data, AssetKey) % return a text file called 'rates123.txt.
end

