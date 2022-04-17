function indx = mapContractChain(contractChainStr,monthMap)

if iscell(contractChainStr)
   contractChainStr = contractChainStr{1,1}; 
end % if

indx = ones(1,length(contractChainStr));
for i = 1:length(contractChainStr)
    indx(i) = find(strcmp(monthMap,contractChainStr(i)),1); 
end % for
end % fn
