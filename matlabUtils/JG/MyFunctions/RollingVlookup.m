function [contvect, indvect] = RollingVlookup(RefMatrix, SourceMatrix, ColTargetSM, ColRefSM)
%
%__________________________________________________________________________
% 
% This function uses the "vlookup.m" function which reproduces the Excel 
% Vlookup function. "vlookup.m" looks for one element only in a set whereas
% RollingVlookup looks for all elements in a given range
% Example of "vlookup.m': 
% m = {1, 'a', [2 3];   2, 'b', 'cd' ;   3, 'a', true};
% [content, index] = vlookup(m, 'a', 3, 2) 
%                    search "a" in the 2nd column of matrix "m" 
%                    and yields element located in the 3rd column of "m" in
%                    the same row.
% INPUT:
% RefMatrix:       the Reference Matrix which is the base on wich the
%                  vlookup is carried out. It is MANDATORY that it is 
%                  vector column of dates in the doule format
% SourceMatrix:    the Source Matrix from which we extract the element to
%                  "vlookup".
%                  It is MANDATORY that The source Matrix contain at least
%                  2 columns and tht the first column be a column of dates
%                  with the same format than RefMatrix
% ColRefSM:        the specific column in the Source Matrix which is
%                  "vlooked-up" on "RefMatrix". Generealy it is column 1
% ColTargetSM:     the specific column in the Source Matrix which is
%                  retrieved (for instance, the close).
%
% Example: assume you build a pair trading SP500 vs Hang Seng and you do
% not want to intersect the data but keep allign the the time series of
% Hang Seng on the one of SP500
% RefMatrix is the data (date + data) matrix for SP500
% SourceMatrix is data (date + data) matrix for Hang Seng with date in
% column 1 and let s say close in column 4
% If you want to retrieve the close, write:
%[contvect, indvect] = RollingVlookup(SP500, hangSeng, 2, 1);
% just for old test..RefMatrix=a;SourceMatrix=b;ColTargetSM=2;  ColRefSM=1;
% 
% Joel Guglietta - March 2014
%__________________________________________________________________________
%
% -- Dimmensions & Prelocation --
[RefMatrix_nrows, ~] = size(RefMatrix);
contvect = zeros(RefMatrix_nrows,1);
indvect  = zeros(RefMatrix_nrows,1);
[SourceMatrix_nrows, ~] = size(SourceMatrix);

for i=1:RefMatrix_nrows
    % extract date
    MyDate = RefMatrix(i);
    % vlookup
    [content,index] = vlookup(SourceMatrix, MyDate, ColTargetSM, ColRefSM);
    % assign;
    [n,c]=size(content);
    if ~isempty(content) && n ==1
        contvect(i) = content;
        indvect(i) = index;
    else
        contvect(i) = NaN;
        indvect(i) = NaN;
    end
end
% First row
if isnan(contvect(1)), contvect(1) = 0; end
if isnan(indvect(1)), indvect(1) = 0; end
% Row > 2
for i=2:RefMatrix_nrows
    if isnan(contvect(i))
        contvect(i) = contvect(i-1);
    end
    if isnan(indvect(i))
        indvect(i) = indvect(i-1);
    end        
end

