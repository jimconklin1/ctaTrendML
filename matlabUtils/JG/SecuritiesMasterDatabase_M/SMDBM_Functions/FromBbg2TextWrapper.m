function FromBbg2TextWrapper(path, data, method, Argument)
%
%_________________________________________________________________________
%
% This function dlmwrite Blommberg's data on a text file
%
% Two methods:
% - write a text file when the Argument is string
% - write a text file when the Argument is a counter in a list
%   this allows for several "genric" names
%   . asset
%   . inst
%   . macro
%   . swap
%   . rates
%   . stock
% Input:

%__________________________________________________________________________
%

switch method
    
    case{'Variable Name', 'variable name', 'VarName', 'varname'}
            
        dlmwrite(strcat(path,Argument,'.txt'),data, 'precision', 14, 'delimiter', ',');
        
    case {'ListMacro','listmacro', 'listMacro'}
        
        dlmwrite(strcat(path,sprintf('macro%d.txt', Argument)),data, 'precision', 14, 'delimiter', ',');

    case {'ListInst','listinst', 'listInst'}
        
        dlmwrite(strcat(path,sprintf('inst%d.txt', Argument)),data, 'precision', 14, 'delimiter', ',');  
        
    case {'ListAsset','listasset', 'listAsset'}
        
        dlmwrite(strcat(path,sprintf('asset%d.txt', Argument)),data, 'precision', 14, 'delimiter', ',');    
        
    case {'ListSwap','listswap', 'listSwap'}
        
        dlmwrite(strcat(path,sprintf('swap%d.txt', Argument)),data, 'precision', 14, 'delimiter', ',');      
        
    case {'ListStock','liststock', 'listStock'}
        
        dlmwrite(strcat(path,sprintf('stock%d.txt', Argument)),data, 'precision', 14, 'delimiter', ',');          
        
end

return