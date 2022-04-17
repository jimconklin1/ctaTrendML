function hrpWts = HRPBistAlg(clusterOrder,covMat)
    
    wts = ones(length(clusterOrder),1);
    L = length(clusterOrder);
    ncols = clusterOrder;
    Lnext = [];
    while L>1
          L1 = ncols(1:floor(L/2));
          L2 = ncols(~ismember(ncols,L1));
          v1 = covMat(L1,L1);
          v2 = covMat(L2,L2);
          w1 = (1./diag(v1))*(1./sum(1./diag(v1)));
          w2 = (1./diag(v2))*(1./sum(1./diag(v2)));
          vt1 = w1' * v1 * w1;
          vt2 = w2' * v2 * w2;
          alpha = 1 - vt1/(vt1+vt2);
          wts(L1) = wts(L1)*alpha;
          wts(L2) = wts(L2)*(1-alpha);
          if (length(L1)>1)
            L = length(L1);
            ncols = L1;
            Lnext = [{L2};{Lnext}];
          elseif and(length(L1)==1,length(L2)>1)
            L = length(L2);
            ncols =  L2;
          elseif and(and(length(L1)==1,length(L2)==1),length(Lnext)>1)
            L = length(cell2mat(Lnext(1)));
            ncols = cell2mat(Lnext(1));
            Lnext = Lnext(2:end);
            Lnext = Lnext{:};
          else
            L = 1;   
          end
    end
    
    hrpWts = wts;
    
end