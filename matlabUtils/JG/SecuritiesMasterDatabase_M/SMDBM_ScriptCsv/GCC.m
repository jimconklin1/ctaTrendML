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
EndDate = '10/28/2014';
%
% -- Master Destination Path --
path = 'S:\00 Individuals\Joel\GCC\';

% Dowload Bloomberg History
% Alternative: 'VWO US Equity'='EEm US Equity',
TickerList = {'MXAE Index', 'SP1 PIT Index', 'UX1 Index', 'VIX Index', 'USGG10YR Curncy','USGG2YR Curncy', 'US1 Comdty', 'UAE US Equity'}; 
for i=1:length(TickerList)
    AssetKey = i;    TickerName = TickerList(AssetKey);
    data = GetBbgHist(ConBbg, TickerName, 0,0, StartDate, EndDate); % No VWAP and No VOlume For rates
    % Save data under a text format with dynamic name
    FromBbg2Text(path, data, AssetKey) % return a text file called 'rates123.txt.
end

