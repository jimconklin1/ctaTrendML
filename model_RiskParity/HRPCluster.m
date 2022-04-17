function hrpWts = HRPCluster(dataStruct,rtns) %#ok<INUSL>
    
    corMat = corr(rtns);
    covMat = cov(rtns);
    % convert correlation into a distance measure, distance = sqrt *
    % (0.5*(1-rho))
    corDist = sqrt(0.5*(1-abs(corMat)));
    % step 1: get hierarchical clustering details for euclidean distance & single
    % linkage
    Z = linkage(corDist,'single','euclidean');
    % Z= linkage(corMat,'single','euclidean');
    % check for optimal number of clusters for data check/research purpose
    % wssTest = chooseCluster(dataStruct,corDist); %#ok<NASGU>
    % wssTest = chooseCluster(dataStruct,corMat); %#ok<NASGU>

    % step 2: re-order matrix
    clusterOrder = HRPReorder(Z);
    
    % step 3: pseduo inverse matrix
    hrpWts = HRPBistAlg(clusterOrder,covMat);
    
end