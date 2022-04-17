function FromBbg2TextAppend_Rates(path, data, AssetKey)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%__________________________________________________________________________
%
dlmwrite(strcat(path,sprintf('rates%d.txt', AssetKey)), data, 'precision', 14, 'delimiter', ',', '-append');

return