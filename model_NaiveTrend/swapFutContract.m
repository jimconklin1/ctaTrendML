function struct = swapFutContract(struct,currStr1,newStr1)
if ~iscell(newStr1)
   newStr1 = {newStr1}; 
end % if
ii = find(strcmp(struct.header,currStr1)); 
for i = 1:length(ii)
   struct.header(ii(i)) = newStr1;
end % for i
end % fn