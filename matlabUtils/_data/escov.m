function [covmtx] = escov(rets, hl, freq, vseeds, mseeds, bufferLen, volFloor, timeUnits)

% This functions creates an exponentially smoothed covariance matrix from a matrix of 
% returns.
%
% rets	=	a T x N matrix of returns
% hl		= 	the half-life of the exponential smoothing
% freq	= 	frequency of the data.
%				D = daily
%				M = monthly
%				Y = yearly
% vseeds	=	the initial covariance matrix estimate (seeds)
% mseeds	=	the optional mean estimate (seeds)
% volFloor  = minimum annualized voaltility applied to the diags of the
%             covar matrices
%
% If mseeds is omitted, the initial seeds are assumed to be zero.

[t, n] = size(rets);
covmtx = zeros(n,n,t);
gamma = 0.5^(1/hl);

if nargin <6 || isempty(bufferLen)
   bufferLen = round(min([5*hl,length(rets)/40]));
end % if 

if nargin < 7 || isempty(volFloor)
    volFloor = 0;
end
    
if nargin < 8 || isempty(timeUnits)
    timeUnits = 'A'; % default is monthly variance 
end

frstActv = calcFirstActive(rets,true); 

% calculate the exponentially smoothed means; 
% if mseeds empty, set the seeds to 0 and calc the means;
% if mseeds = 0, set ALL means to zero.
if nargin < 5 || isempty(mseeds)
   mseeds = 99999; % flag to be replaced below
end % if
if mseeds(1,1)==0
   means = zeros(size(rets)); 
elseif mseeds(1,1)==99999
   mseeds = zeros(1,n); 
   means = calcEWA(rets,hl,mseeds);
else
   means = calcEWA(rets,hl,mseeds);
end
means(isnan(means))=0;

if nargin < 4 || isempty(vseeds)
  t0 = min(max(frstActv),(t-bufferLen)); 
  t1 = min((t0 + bufferLen),t); 
  vseeds = cov(rets(t0:t1,:)); 
  vseeds(isnan(vseeds)) = 0; 
end % if

if nargin < 3 || isempty(freq) 
   freq = 'D';
end 
freq = upper(freq); 
freq = freq(1); 
timeUnits = upper(timeUnits); 
timeUnits = timeUnits(1); 

if strcmp(freq,'D') && (strcmp(timeUnits,'Y')||strcmp(timeUnits,'A'))
    adjfac = 260;
elseif strcmp(freq,'D') && strcmp(timeUnits,'M')
    adjfac = 21;
elseif strcmp(freq,'D') && strcmp(timeUnits,'D')
    adjfac = 1;
elseif strcmp(freq,'M') && (strcmp(timeUnits,'Y')||strcmp(timeUnits,'A'))
    adjfac = 12;
elseif strcmp(freq,'M') && strcmp(timeUnits,'M')
    adjfac = 1;
elseif strcmp(freq,'M') && strcmp(timeUnits,'D')
    adjfac = 1/21;
elseif (strcmp(freq,'Y')||strcmp(freq,'A')) && (strcmp(timeUnits,'Y')||strcmp(timeUnits,'A'))
    adjfac = 1;
elseif (strcmp(freq,'Y')||strcmp(freq,'A')) && strcmp(timeUnits,'M')
    adjfac = 1/12;
elseif (strcmp(freq,'Y')||strcmp(freq,'A')) && strcmp(timeUnits,'D')
    adjfac = 1/260;
else 
    adjfac = 1;
end % if

% calculate the exponentially smoothed variances and covariances
covmtx(:,:,1) = vseeds; 
for i = 2:t
   for j = 1:n
      for k = 1:n
%          if i == 1
%             covmtx(j,k,i)=gamma.*vseeds(j,k)+(1-gamma).*((rets(i,j)-means(i,j))*(rets(i,k)-means(i,k)));
%             if (isnan(rets(i,j)) || isnan(rets(i,k)))
%                covmtx(j,k,i) = vseeds(j,k);
%             end
%          else
            covmtx(j,k,i)=gamma.*covmtx(j,k,i-1)+(1-gamma).*((rets(i,j)-means(i,j))*(rets(i,k)-means(i,k)));
            if (isnan(rets(i,j)) || isnan(rets(i,k))) || (i < frstActv(j)) || (i < frstActv(k))
               covmtx(j,k,i) = covmtx(j,k,i-1);
            end
                                   
%         end % if i
      end % for k
   end % for j
end % for i       

% compute min variance, if needed
if (volFloor > 0)
    varianceFloor = (volFloor ^ 2);
    for i=1:size(covmtx, 3)
        variances = diag(covmtx(:, :, i));
        inx = find(variances < varianceFloor);
        if (~isempty(inx))
            for n=1:length(inx)
                covmtx(inx(n), inx(n), i) = varianceFloor;
            end
        end                  
    end
end

covmtx=adjfac.*covmtx;
end % fn 