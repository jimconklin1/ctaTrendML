
myData  = magic(4); % array
myList={'equ','commo'}; % List
listIndex=2;
i=20;                   % index
myName = strcat(myList(2),sprintf('%0.5g',i),'.mat'); % set any name with numerical index
myNameShort = strcat(myList(listIndex),sprintf('%0.5g',i)); % set any name with numerical index
junk.('junkName')=myData;
junk.(myNameShort{1})=myData;
save(myNameShort{1}, '-struct', 'junk')
a.(myName{1})=myData;
save('Data.mat','-struct','a',myNameShort{1})

   currentFile = sprintf('myfile%d.mat',3);
   save(currentFile,'myData')

%myName = strcat(myList(listIndex),sprintf('%0.5g',i)); % set any name with numerical index

%assignin('base', myName{1}, myData)

RunEx1=0;
if RunEx1==1
    numFiles = 10;
    for n = 1:numFiles
       randomData = rand(n);
       currentFile = sprintf('myfile%d.mat',n);
       save(currentFile,'randomData')
    end
end

%myName.('junkName') = myData;

%save(myName{1}, '-struct', 'junk')
%save(myName{1}, '-struct', 'junk')



%eval(['save' 

