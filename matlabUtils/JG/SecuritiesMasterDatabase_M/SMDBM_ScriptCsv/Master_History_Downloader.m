%
%__________________________________________________________________________
%
% MASTER BLOOMBERG DOWNLOADER
%
% 1. Loops through the universe
% 2. Create Matlab Structures
% 3. Save them as txt
% 4. Export txt them to MySQL
%
%__________________________________________________________________________

%
% Open Bloomber Connection
clear all
clc
ConBbg = bloomberg;%(8194,'10.50.100.120') % too many connections, dun know why, just need bloomberg and ok
% Master Path
path = 'S:\08 Trading\088 Quantitative Global Macro\0880 MatlabDataBaseManager\';

% Start & End Date for dowload
StartDate = '01/01/1980';  %MM/DD/YYY
EndDate = '03/28/2014';    %MM/DD/YYY
PointDate = '03/30/2014';  %MM/DD/YYY

for i = 1: NbInstruments
    
    if MasterAssetMatrix(i,2) == 1 % Asset is in
        % hIS
        if MasterAssetMatrix(i,3) == 0 % Intersect address = 0 means no intersection
            % Dowload Bloomberg History
            AssetKey = MasterAssetMatrix(i,1);
            TickerName = TickerList(AssetKey);
            data = GetBbgHist(ConBbg, TickerName, StartDate, EndDate);
            % Save data under a text format with dynamic name
            FromBbg2Text(path, data, AssetKey) % return a text file called 'asset123.txt.
        end
        if MasterAssetMatrix(i,3) > 0 % Intersect address > 0 means intersection
            % Dowload Bloomberg History
            AssetKey = MasterAssetMatrix(i,1);
            TickerName = TickerList(AssetKey);
            dataGross = GetBbgHist(ConBbg, TickerName, StartDate, EndDate);
            % Dowload Bloomberg History of instrument
            AssetKeyBench = MasterAssetMatrix(i,3);
            TickerNameBench = TickerList(AssetKeyBench);
            dataBench = GetBbgCloseHist(ConBbg, TickerName, StartDate, EndDate);
            % Vlookup on benchmark            
            data = VlookpInstrument(dataBench, dataGross);
            % Save data under a text format with dynamic name
            FromBbg2Text(path, data, AssetKey) % return a text file called 'asset123.txt.
        end        
    end
end