function FromBbg2TextAppend(path, data, AssetKey)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,sprintf('asset%d.txt', AssetKey)), data, 'precision', 14, 'delimiter', ',', '-append');

return