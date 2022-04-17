function indx = mapStringsi(subset,univ,allowZeros)
% this function maps each string in cell array "subset" 
%   to its location in the cell array "univ"
if size(subset,1) > size(subset,2)
   subset = subset'; 
end % if

if size(univ,1) > size(univ,2)
   univ = univ'; 
end % if

if nargin < 3 || isempty(allowZeros)
   allowZeros = true; 
end % if

indx = zeros(1,length(subset)); 
for i = 1:length(subset)
   iTemp = find(strcmpi(univ,subset(i)),1); 
   if ~isempty(iTemp)
      indx(1,i) = iTemp;
   end 
end % for 

if ~allowZeros
   indx = indx(indx~=0);
end % if

end % fn