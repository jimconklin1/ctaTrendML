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
EndDate = '10/27/2014';
% -- Master Destination Path --
path = 'S:\00 Individuals\Joel\IH1Model\';

% Dowload Bloomberg History
TickerList = {'INPIINDY Index', 'INPIINY9 Index', 'INVSTOTL Index', 'INMSM1Y Index'}; 
for i=1:length(TickerList)
    AssetKey = i;    TickerName = TickerList(AssetKey);
    data = GetBbgHistMacro(ConBbg, TickerName, StartDate, EndDate); % No VWAP and No VOlume For rates
    % Save data under a text format with dynamic name
    FromBbg2Text_Macro(path, data, AssetKey) % return a text file called 'rates123.txt.
end