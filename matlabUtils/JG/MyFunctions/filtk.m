function  yf=filtk(y,a)

% Filter data with a filter with symmetric filter with weights
% data is organized (rows=obs, columns=series)
% a=[a0 a1 ... aK];

K=max(size(a))-1;  % max lag;

T=max(size(y));    % number of observations;

% Set vector of weights

avec=zeros(1,2*K+1);
avec(K+1)=a(1);
for i=1:K;
avec(K+1-i)=a(i+1);
avec(K+1+i)=a(i+1);
end
yf=zeros(size(y));
for t=K+1:1:T-K
 yf(t,:)=avec*y(t-K:t+K,:);
end

