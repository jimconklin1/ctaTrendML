function FromBbg2Text_Factor(path, data, AssetKey)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,sprintf('cf%d.txt', AssetKey)),data, 'precision', 14, 'delimiter', ',');

return