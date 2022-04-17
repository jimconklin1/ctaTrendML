function myNum = cell2Num(x)
%
for i = 1:length(x)
   b(i) = str2num(cell2mat(x(i,1))); 
end

myNum=b(1,1);