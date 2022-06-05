function cokurt = SampleCokurtosis(data)
%etimate mean
mu = mean(data,1);
%deman
cdata = data-mu;

N = size(cdata,2);
cokurt = zeros(N,N*N*N);
for i= 1:N
    for j=1:N
        for k=1:N
           for l=1:N 
               cokurt(k,((i-1)*N+j-1)*N+l) = mean(cdata(:,i).*cdata(:,j).*cdata(:,k).*cdata(:,l));
           end
        end
    end
end