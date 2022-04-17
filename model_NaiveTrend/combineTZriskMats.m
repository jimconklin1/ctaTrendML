function [covmtx, dates] = combineTZriskMats(covmtxTK,datesTK,covmtxLN,datesLN,...
                                             covmtxNY,datesNY,executionTZ,dataConfig)
% parse possible input strings on execution time zone argument:
if strcmpi(executionTZ,'postTK')||strcmpi(executionTZ,'postTokyo')||strcmpi(executionTZ,'postTKClose')...
        ||strcmpi(executionTZ,'postTokyoClose')
   executionTZ = 'postTokyoClose'; 
elseif strcmpi(executionTZ,'postLN')||strcmpi(executionTZ,'postLondon')||strcmpi(executionTZ,'postLNClose')...
        ||strcmpi(executionTZ,'postLondonClose')
   executionTZ = 'postLondonClose'; 
elseif strcmpi(executionTZ,'postNY')||strcmpi(executionTZ,'postNewYork')||strcmpi(executionTZ,'postNewYorkClose')...
        ||strcmpi(executionTZ,'postNYClose')
   executionTZ = 'postNYClose'; 
end
date0 = floor(min([datesTK(1),datesLN(1),datesNY(1)]));

switch executionTZ
    case 'postTokyoClose'
       % NOTE: modified to give preference to LN data in TK TZ
%       sesCls = dataConfig.assetSessionSelect.postTK; 
       while floor(datesTK(1)) > floor(date0)
%           covmtxTK = cat(3,covmtxTK(:,:,1),covmtxTK); 
          covmtxTK = cat(3,covmtxLN(:,:,1),covmtxTK); 
          datesTK = [busdate(datesTK(1),-1); datesTK]; %#ok<AGROW>
       end % if
       dates = datesTK; 
       covmtx = covmtxTK; 
       T = length(dates); 
       N = size(covmtx,1); 
       temp = squeeze(covmtx(:,:,1));
       temp(isnan(temp))=0;
       dTemp = diag(temp);
       ii = find(dTemp==0);
       if ~isempty(ii)
          indx = setdiff((1:N),ii); 
          param = mean(dTemp(indx)); 
          for i = 1:length(ii)
             temp(ii(i),ii(i)) = param; 
          end 
       end % if
       covmtx(:,:,1) = temp;
       for t = 2:T
           tL = find(datesLN<dates(t),1,'last');
          tN = find(datesNY<dates(t),1,'last');
           % start with London as default cleanest var-cov matrix:
           if ~isempty(tL)
               covmtx(:,:,t) = covmtxLN(:,:,tL); 
           elseif ~isempty(tN)
               covmtx(:,:,t) = covmtxNY(:,:,tN); 
           else
               covmtx(:,:,t) = covmtx(:,:,t-1); 
           end % if
%           if ~(isempty(tL) && isempty(tN))
           if ~isempty(tL)
               for i = 1:size(covmtx,1)
                   for j = 1:size(covmtx,2)
%                        if (strcmpi(sesCls(i),'TK') || strcmpi(sesCls(j),'TK')) && ~isnan(covmtxTK(i,j,t))
%                            covmtx(i,j,t) = covmtxTK(i,j,t);
%                        elseif ~isempty(tN) && (strcmpi(sesCls(i),'NY') && strcmpi(sesCls(j),'NY')) && ~isnan(covmtxNY(i,j,t))
%                            covmtx(i,j,t) = covmtxNY(i,j,tN);
%                        end % if
                       if isnan(covmtx(i,j,t))
                          covmtx(i,j,t) = covmtx(i,j,t-1); 
                       end 
                   end % for j
               end % for i
           end % if
       end % for

    case 'postLondonClose'
       sesCls = dataConfig.assetSessionSelect.postLN; 
       while floor(datesLN(1)) > floor(date0)
          covmtxLN = cat(3,covmtxLN(:,:,1),covmtxLN); 
          datesLN = [busdate(datesLN(1),-1); datesLN]; %#ok<AGROW>
       end % if
       dates = datesLN; % use London dates
       covmtx = covmtxLN;
       T = length(dates); 
       N = size(covmtx,1); 
       temp = squeeze(covmtx(:,:,1));
       temp(isnan(temp))=0;
       dTemp = diag(temp);
       ii = find(dTemp==0);
       if ~isempty(ii)
          indx = setdiff((1:N),ii); 
          param = mean(dTemp(indx)); 
          for i = ii
             temp(i,i) = param; 
          end 
       end % if
       covmtx(:,:,1) = temp; 
       for t = 2:T
           tT = find(datesTK<dates(t),1,'last');
           tN = find(datesNY<dates(t),1,'last');
           if ~(isempty(tT) && isempty(tN))
               for i = 1:size(covmtx,1)
                   for j = 1:size(covmtx,2)
                       if ~isempty(tT) && (strcmpi(sesCls(i),'TK') && strcmpi(sesCls(j),'TK')) && ~isnan(covmtxTK(i,j,t))
                           covmtx(i,j,t) = covmtxTK(i,j,tT);
                       elseif ~isempty(tN) && (strcmpi(sesCls(i),'NY') && strcmpi(sesCls(j),'NY')) && ~isnan(covmtxNY(i,j,t))
                           covmtx(i,j,t) = covmtxNY(i,j,tT);
                       end % if
                       if isnan(covmtx(i,j,t))
                          covmtx(i,j,t) = covmtx(i,j,t-1); 
                       end 
                   end % for j
               end % for i
           end 
       end % for

    case 'postNYClose'
       sesCls = dataConfig.assetSessionSelect.postNY; 
       while floor(datesNY(1)) > floor(date0)
         covmtxNY = cat(3,covmtxNY(:,:,1),covmtxNY); 
         datesNY = [busdate(datesNY(1),-1); datesNY]; %#ok<AGROW>
       end % if
       dates = datesNY; % use NY dates
       covmtx = covmtxNY;
       T = length(dates); 
       N = size(covmtx,1); 
       temp = squeeze(covmtx(:,:,1));
       temp(isnan(temp))=0;
       dTemp = diag(temp);
       ii = find(dTemp==0);
       if ~isempty(ii)
          indx = setdiff((1:N),ii); 
          param = mean(dTemp(indx)); 
          for i = ii
             temp(i,i) = param; 
          end 
       end % if
       covmtx(:,:,1) = temp;       for t = 2:T
           tT = find(datesTK<dates(t),1,'last');
           tL = find(datesLN<dates(t),1,'last');
           if ~isempty(tL)
               covmtx(:,:,t) = covmtxLN(:,:,tL); 
           else
               covmtx(:,:,t) = covmtx(:,:,t-1); 
           end % if
           if ~(isempty(tT) && isempty(tL))
               for i = 1:size(covmtx,1)
                   for j = 1:size(covmtx,2)
                       if (strcmpi(sesCls(i),'NY') || strcmpi(sesCls(j),'NY')) && ~isnan(covmtxNY(i,j,t))
                           covmtx(i,j,t) = covmtxNY(i,j,t);
                       elseif ~isempty(tT) && (strcmpi(sesCls(i),'TK') && strcmpi(sesCls(j),'TK')) && ~isnan(covmtxTK(i,j,t))
                           covmtx(i,j,t) = covmtxTK(i,j,t);
                       end % if
                       if isnan(covmtx(i,j,t))
                          covmtx(i,j,t) = covmtx(i,j,t-1); 
                       end 
                   end % for j
               end % for i
           end % if
       end % for

end % switch
end % fn