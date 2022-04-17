function outStruct = fetchTstats( Ids, lookbacks , startDate , endDate , close )


if ~ischar(startDate)
   startDate = datestr(startDate,'yyyy-mm-dd'); 
end 

if ~ischar(endDate)
   endDate = datestr(endDate,'yyyy-mm-dd'); 
end

if nargin < 5 || isempty(close) 
   close= nan; 
else
    if strcmpi(close,'tokyo')||strcmpi(close,'tyo') ||strcmpi(close,'tk') 
      close = 'tyo';
   elseif strcmpi(close,'london')||strcmpi(close,'lon')||strcmpi(close,'lndn') ||strcmpi(close,'ln')
      close = 'lon';
   elseif strcmpi(close,'newyork')||strcmpi(close,'ny')||strcmpi(close,'nyc')
      close = 'nyc';
   end % if
end % if

N = length (Ids); 
K = length (lookbacks) ; 
keys = Ids ; 
for n =1 :N
    if strcmpi ( keys{n}(1:3), 'fx.'); keys{n}= Ids{n}(4:end) ; end ; 
    keys{n}= strrep (keys{n}, ' ','_'); 
    keys{n} = strcat('u.d.tstat_',keys{n});
end 
tempkeys = repmat (keys,1, length(lookbacks));

for k=1 : K
    L = lookbacks (k); 
    for n = (k-1)*N+1:k*N
        tempkeys{n}=strcat (tempkeys{n},'_',num2str(L)  );
    end 
end 
if ~isnan(close)
    tempData =table2array( tsrp.fetch_one( tempkeys, 'udts',  [], startDate , endDate, true, strcat('close=',close)));
else 
    tempData= table2array(tsrp.fetch_one( tempkeys, 'udts',  [], startDate , endDate, true, []));
end 




if isempty (tempData)
   datesOut = []; 
   tstatCube= [];
else 
    [T, ~]= size (tempData); 
    tstatCube= nan (T, N, K); 
    for  k=1 : K
        tstatCube (:,: ,k)= tempData (:,(k-1)*N+2:k*N+1); 
    end 
    datesOut = tempData(:,1); 
end 

outStruct.header = Ids ; 
outStruct.lookbacks = lookbacks ; 
outStruct.dates = datesOut;
outStruct.values= tstatCube;

end

