function FromBbg2Text(path, data, InstKey)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,sprintf('inst%d.txt', InstKey)),data, 'precision', 14, 'delimiter', ',');

return