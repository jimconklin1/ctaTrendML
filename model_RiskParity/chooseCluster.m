function wss = chooseCluster(dataStruct,corDist,number)
    
    if ~exist('number','var')        
        wss = zeros(length(dataStruct.header)-1,2);
        for i = 2:length(dataStruct.header)
            clust = clusterdata(corDist,'distance','euclidean','linkage','single',i);
            wss(i-1,1) = i;
            if i >= max(clust)
                clusts = unique(clust);
                sss = 0;
                for j = 1:length(clusts)
                    tmp = unique(corDist(ismember(clust,j),ismember(clust,j)));
                    ss = (tmp-mean(tmp))'*(tmp-mean(tmp));
                    sss = ss + sss;
                end
                wss(i-1,2) = sss; 
            else
                wss(i-1,2) = 0;
            end
        end

        x = wss(:,1);
        y = wss(:,2);
        figure(2); plot(x,y,'-o');title('choose number of clusters');xlabel('number of clusters');ylabel('sum of squares within clusters');grid;
    else
        clust = clusterdata(corDist,'distance','euclidean','linkage','single',number);
        wss = zeros(length(dataStruct.header),2);
        wss(:,1) = 1:length(dataStruct.header);
        wss(:,2) = clust;
    end
    
end