function FromBbg2Text_Macro(path, data, AssetKey)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,sprintf('macro%d.txt', AssetKey)),data, 'precision', 14, 'delimiter', ',');

return