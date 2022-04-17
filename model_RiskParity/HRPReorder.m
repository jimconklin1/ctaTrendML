function clusterOrder = HRPReorder(Z)

   tmp1 = Z(:,1);
   tmp2 = Z(:,2);
   dims = (size(Z,1)+1);
   totalindex = [];
   order_list = [];
   tmp1max = tmp1(end);
   tmp2max = tmp2(end);
   tmp2max0 = [];
   
    while ~isempty(tmp1max)              
             
        if and(tmp2max > dims,tmp1max <= dims)
            index = find(ismember(tmp1,tmp1max)); 
            if ~ismember(index,totalindex)
                totalindex = [totalindex;index]; %#ok<AGROW>
            end
            leaf = tmp1(index);
            if isempty(order_list)
                order_list = [order_list;leaf]; %#ok<AGROW>
            else
                if ~ismember(leaf,order_list)
                    order_list = [order_list;leaf]; %#ok<AGROW>
                end
            end
            index2 = tmp2max - dims;
            tmp1max = tmp1(index2);
            tmp2max = tmp2(index2);
        
        elseif and(tmp2max <= dims,tmp1max <= dims)
            index = find(ismember(tmp1,tmp1max)); 
            if ~ismember(index,totalindex)
                totalindex = [totalindex;index]; %#ok<AGROW>
            end
            leaf = [tmp1(index);tmp2(index)];
            order_list = [order_list;leaf]; %#ok<AGROW>
            if isempty(tmp2max0)
                index2 = find(ismember(tmp1,max(tmp1(setdiff(1:dims-1,totalindex)))));
            else
                index2 = tmp2max0(1);
                tmp2max0 = tmp2max0(2:end);
            end
            tmp1max = tmp1(index2);
            tmp2max = tmp2(index2);
            
         elseif and(tmp2max <= dims,tmp1max > dims)
            index = find(ismember(tmp2,tmp1max)); 
            if ~ismember(index,totalindex)
                totalindex = [totalindex;index]; %#ok<AGROW>
            end
            leaf = tmp2(index);
            if ~ismember(order_list,leaf)
                order_list = [order_list;leaf]; %#ok<AGROW>
            end
            index2 = tmp1max - dims;
            tmp1max = tmp1(index2);
            tmp2max = tmp1(index2);           
         
        elseif and(tmp2max > dims,tmp1max > dims)
            index = find(ismember(tmp2,tmp2max)); 
            if ~ismember(index,totalindex)
                totalindex = [totalindex;index]; %#ok<AGROW>
            end
            tmp1max0 = tmp1max-dims;
            tmp2max0 = [tmp2max - dims;tmp2max0]; %#ok<AGROW>
            tmp1max = tmp1(tmp1max0);
            tmp2max = tmp2(tmp1max0);             
      
        end

        
    end

    clusterOrder = order_list;
    
    

end
