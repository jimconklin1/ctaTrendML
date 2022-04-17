
function [content, index] = vlookup(m, e, column, lookcolumn)
%__________________________________________________________________________
%VLOOKUP the function as vlookup in Excel
%
%   [content, index] = vlookup(m, e, column, lookcolumn) look for 'e' in 
%   the 'lookcolumn'-th column of 'm', and return the coresponding
%   'column'-th element of 'm' in the same row.
%
%   the 'm' could be a numeric matrix of a cell matrix.
% 
%   lookcolumn is 1 by default if omitted.
% 
% Example:
% m = {1, 'a', [2 3];   2, 'b', 'cd' ;   3, 'a', true};
% m = {1, 'dna', pi;   2, 'b', 'cd' ;   3, 'a', 5};
% m = [1, 11, 111;   2, 22, 222 ;   3, 33, 333];
%   [content, index] = vlookup(m, 'a', 3, 2) then
% cherche element 'a' dans matrice la seconde colonne de la matrice m et si
% tu le trouves, renvoie l'elment de la 3ieme colonne sur la meme ligne
% content = {[2 3], 1};
% index = [1;3]
%__________________________________________________________________________

if isempty(m) || isempty(e), return; end
if nargin <= 3, lookcolumn = 1; end

isechar = ischar(e);
assert(isechar || isnumeric(e), 'the second parameter must be a string or numeric');

if iscell(m)
    content = {}; index = [];
    if isechar
        %index = find(strcmp(e, m(:, lookcolumn)));
        index = find(strcmpi(e, m(:, lookcolumn)));
        content = m(index, column);
    else
        for i = 1:size(m, 1)
            if isnumeric(m{i, lookcolumn}) && m{i, lookcolumn} == e
                content = [content; m(i, column)]; %#ok<*AGROW>
                index = [index; i];
            end
        end
    end
else
    assert(~isechar, 'When the first para is a matrix, the second para must be numeric');
    
    index = find(m(:, lookcolumn) == e);
    content = m(index, column);
end