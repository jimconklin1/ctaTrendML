function [datev, dateBbg, o, h, l, c] = UploadBbgCSV_Rates_OHLC(path , AssetKey)
%
%__________________________________________________________________________
%
% This macro upload a text file where Dates, Open, High, Low, CLose from
% Bloomberg have bee saved
% Input:
% AssetKey: the position number of the instrument in the tickers' list
% path:     a string showing where the mat file.
%
%__________________________________________________________________________

% -- Upload asset total history --
OptionRead = 2;
if OptionRead == 1
    data = csvread(strcat(path,sprintf('asset%d.mat', AssetKey)));
elseif OptionRead == 2
    data = dlmread(strcat(path,sprintf('asset%d.txt', AssetKey)));%, 'delimiter', ',',);
end
%
% -- Extract Date string into double (str2num quicker than str2double) --
nrows = length(data);
datev = zeros(nrows,1);
for i =1:nrows
    datep = num2str(data(i,1)); % double
    datev(i) = str2num(strcat(datep(1:4),datep(5:6), datep(7:8))); 
end
dateBbg = data(:,2);
% -- Extract Data --
o = data(:,3);    h = data(:,4);
l = data(:,5);    c = data(:,6);
clear data AssetKey
