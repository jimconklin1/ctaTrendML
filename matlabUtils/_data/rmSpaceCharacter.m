function outVar = rmSpaceCharacter(inVar)
outVar = inVar;
if iscell(inVar)
   [M,N] = size(inVar);
   for m=1:M
       for n = 1:N
           tempStr = inVar{m,n};
           indx = tempStr ~= ' ';
           outVar{m,n} = tempStr(indx);
       end % n
   end % m
else
   disp('rmSpaceCharacter only operates on cell arrays containing character strings')    
   disp('input variable is returned unaltered')    
end