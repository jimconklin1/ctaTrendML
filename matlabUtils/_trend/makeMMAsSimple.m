function struct = makeMMAsSimple(freqOpt)
if nargin<1 || isempty(freqOpt)
   freqOpt = 'long';
end
% create the support for the front and back moving average look-backs:
if ischar(freqOpt)
    if strcmp(freqOpt,'long')
        x1 = 2:30;
        aa = [4,5,7,10];
        minL2 = zeros ( 1, length (x1)) ;
        maxL2 =  inf( 1, length (x1)) ;
        MAs = ones(length(x1)*length(aa),2);
    else % freqOpt == 'short'
        x1 = 2:15;
        aa = [4,5,7,10];
        minL2 = zeros ( 1, length (x1)) ;
        maxL2 = inf ( 1, length (x1)) ;
        MAs = ones(length(x1)*length(aa),2);
    end % if
else
    x1 = freqOpt.a;
    aa = freqOpt.b;
    minL2 = freqOpt.L2Min ;
    maxL2 = freqOpt.L2Max ;
    MAs = ones(length(x1)*length(aa),2); 
end;
  
k = 0;
for i = 1:length(x1)
    for j = 1:length(aa)
        l2 = x1(i)*aa(j); 
        if l2>=minL2(i) && l2<=maxL2(i)
            k = k+1;
            MAs(k,:) = [x1(i), l2];
        end 
    end
end
MAs= MAs(1:k,:);
% now create the weighting of the mixture you're going to use over the
%   various look-backs: 
x1 = unique(MAs(:,1));
x2 = unique(MAs(:,2));
y1 = 1/length(x1);
y2 = 1/length(x2);
maWts = zeros(length(MAs),1);
for k = 1:length(MAs)
    maWts(k) = y1*y2;
end % for k
maWts = maWts/sum(maWts);
indx = find(maWts~=0);
struct.ma = MAs(indx,:);
struct.wts = maWts(indx,:);

end % fn

% switch opt 
%     case 1 % front: chi-squared, back: gamma; distribution params apply to [frontMA, backMA]
%         x1 = 1:max(MAs(:,1)); 
%         v1 = 10; 
%         y1 = chi2pdf(x1,v1)'; 
%         
%         x2 = 1:max(MAs(:,2)); 
%         k2 = 2; 
%         theta2 = 40; 
%         y2 = gampdf(x2,k2,theta2); 
%         
%         maWts = zeros(length(MAs),1); 
%         for k = 1:length(MAs)
%            maWts(k) = y1(MAs(k,1))*y2(MAs(k,2)); 
%         end % for k
%         maWts = maWts/sum(maWts); 
%         indx = find(maWts~=0); 
%         struct.ma = MAs(indx,:); 
%         struct.wts = maWts(indx,:); 
%     case 2 % uniform distribution
%         x1 = unique(MAs(:,1)); 
%         x2 = unique(MAs(:,2)); 
%         y1 = 1/length(x1); 
%         y2 = 1/length(x2); 
%         maWts = zeros(length(MAs),1); 
%         for k = 1:length(MAs)
%            maWts(k) = y1*y2; 
%         end % for k
%         maWts = maWts/sum(maWts); 
%         indx = find(maWts~=0); 
%         struct.ma = MAs(indx,:); 
%         struct.wts = maWts(indx,:); 
%     case 3 % mixed 1 and 2 
%         x1 = 1:max(MAs(:,1)); 
%         v1 = 10; 
%         y1 = chi2pdf(x1,v1)'; 
%         y1 = 0.5*y1 + 0.5*ones(size(y1))/length(y1); 
%         
%         x2 = 1:max(MAs(:,2)); 
%         k2 = 2; 
%         theta2 = 40; 
%         y2 = gampdf(x2,k2,theta2); 
%         y2 = 0.5*y2 + 0.5*ones(size(y2))/length(y2); 
%         
%         maWts = zeros(length(MAs),1); 
%         for k = 1:length(MAs)
%            maWts(k) = y1(MAs(k,1))*y2(MAs(k,2)); 
%         end % for k
%         maWts = maWts/sum(maWts); 
%         indx = find(maWts~=0); 
%         struct.ma = MAs(indx,:); 
%         struct.wts = maWts(indx,:);         
% end % switch