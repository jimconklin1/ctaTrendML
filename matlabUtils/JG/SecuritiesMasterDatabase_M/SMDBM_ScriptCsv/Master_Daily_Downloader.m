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
% Ticker List
TickerList={'SP1 COMB Index', 'HI1 COMB Index'};
%                    AssetKey  in/out   Benchmark
MasterAssetMatrix = [1,        1,       0 ; ...
                     2,        1,       0]; 
NbInstruments = 2;

% Start & End Date for dowload
PointDate = '03/31/2014';  %MM/DD/YYY                 
                 
% Check US
[data_usus, inout_us]= GetBbgToday(ConBbg, 'SP1 Index', PointDate);

for i = 1: NbInstruments
    
    if MasterAssetMatrix(i,2) == 1 % Asset in=1 / out=0
        % hIS
        if MasterAssetMatrix(i,3) == 0 % Intersect address = 0 means no intersection
            % Dowload Bloomberg Data Todat
            AssetKey = MasterAssetMatrix(i,1);
            TickerName = TickerList(AssetKey);
            [dataToday, inout] = GetBbgToday(ConBbg, TickerName, PointDate);
            % Save data under a text format with dynamic name
            if inout == 1
                FromBbg2TextAppend(path, dataToday, AssetKey) % return a text file 
            end
        end
        if MasterAssetMatrix(i,3) > 0 % Intersect address > 0 means intersection
            % Dowload Bloomberg Data Today
            AssetKey = MasterAssetMatrix(i,1);
            TickerName = TickerList(AssetKey);
            [dataToday, inout] = GetBbgToday(ConBbg, TickerName, PointDate);
            % Dowload Bloomberg History of instrument
            AssetKeyBench = MasterAssetMatrix(i,3);
            TickerNameBench = TickerList(AssetKeyBench);
            [dataTodayBench, inoutBench] = GetBbgToday(ConBbg, TickerNameBench, PointDate);
            if inoutBench == 1 && inout == 1
                FromBbg2TextAppend(path, dataToday, AssetKey) % return a text file 
            elseif inoutBench == 1 && inout == 0
               % Upload Asset
               [datev, o, h, l, c, vwap, volu] = UploadBbgCSV(path, AssetKey);
               % Carry forward the last row & Concatenate
               nsteps=length(o);
               o=[o;o(nsteps)];             h=[h;h(nsteps)];
               l=[l;l(nsteps)];             c=[c;c(nsteps)];
               vwap=[vwap;vwap(nsteps)];    volu=[volu;volu(nsteps)];
               % Update date vector with today date as Benchmark trades
               bench_date = FormatTodayDate(PointDate);
               datev = [datev ; str2double(bench_date)];
               % Recreate matrix
               data = [datev, o, h, l, c, vwap, volu];
               % Save
               FromBbg2Text(path, data, AssetKey);  % return a text file 
            end
            % Vlookup on benchmark            
            %data = VlookpInstrument(dataBench, dataGross);
            % Save data under a text format with dynamic name
        end        
    end
end