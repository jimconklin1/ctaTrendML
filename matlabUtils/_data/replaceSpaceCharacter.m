function outVar = replaceSpaceCharacter(inVar,newChar,firstCharNotNumber,firstChar)
% 
if nargin < 3
   firstCharNotNumber = false;
   firstChar = [];
elseif nargin < 4
   firstChar = 'x'; 
end 
outVar = inVar;

if ~ischar(newChar) || max(size(newChar))>1
   disp('replacement character either not of type char or is of too great a size (must be a single character)')
   disp('input variable is returned unaltered') 
elseif iscell(inVar)
   if firstCharNotNumber && (~isempty(str2num(firstChar)) || max(size(newChar))>1 || isempty(firstChar))  %#ok<ST2NM>
      disp('front ''filler'' character was not a single, non-numerical charater')
      disp('will insert ''x'' as a default') 
      firstChar = 'x';
   end 
   [M,N] = size(inVar);
   for m=1:M
       for n = 1:N
           tempStr = inVar{m,n};
           indx = tempStr == ' ';
           tempStr(indx) = newChar;
           if firstCharNotNumber && ~isempty(str2num(tempStr(1))) %#ok<ST2NM>
              tempStr = [firstChar,tempStr];  %#ok<AGROW>
           end 
           outVar(m,n) = {tempStr};
       end % n
   end % m
else
   disp('rmSpaceCharacter only operates on cell arrays containing character strings')    
   disp('input variable is returned unaltered')    
end