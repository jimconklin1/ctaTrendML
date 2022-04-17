function data = VlookupInstrument(dataBench, dataGross)
%
%__________________________________________________________________________
%
% Vlookup a matrix on a benchmark
% we assume a data structure where the first column is always a date and
% then data
%__________________________________________________________________________
%
%
% -- Dimensions & prelocation --
[nrowssource, ncolssource] = size(dataGross);
[nrowsbench, ncolsbench] = size(dataBench);
clear ncolsbench nrowssource
data = zeros(nrowsbench, ncolssource);
%
% -- Time stamp --
data(:,1) = dataBench(:,1);
%
% -- Vllokup the matrix --
for j=2:ncolssource
    % Vlookup the frst column
    [vlupcol, junk] = RollingVlookup(dataBench, dataGross, j, 1);
    clear junk
    % Assign
    data(:,j) = vlupcol;
end    
