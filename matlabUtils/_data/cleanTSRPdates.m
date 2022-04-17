function [outDates,outData] = cleanTSRPdates(inDates,inData)
   indx = ~(weekday(inDates(:,1))==1 | weekday(inDates(:,1))==7); % eliminate weekends from price levels 
   outDates = inDates(indx,:); 
   outData = inData(indx,:); 
   outData = rmNaNs(outData); 
   indx2 = outDates(2:end,:)==outDates(1:end-1,:);
   dupeDates = unique(outDates(indx2,:)); 
   indx4 = []; 
   for i = 1:length(dupeDates)
      indx3 = find(outDates==dupeDates(i)); 
      outData(indx3(1),:) = nanmean(outData(indx3,:));
      indx4 = [indx4; indx3(2:end,:)]; %#ok  
   end 
   indx5 = setdiff(1:length(outDates),indx4);
   outDates = outDates(indx5,:); 
   outData = outData(indx5,:); 
end % function
