function FromBbg2Text_VarName(path, data, VarName)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,VarName,'.txt'),data, 'precision', 14, 'delimiter', ',');

return