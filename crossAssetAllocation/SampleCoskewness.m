function coskew = SampleCoskewness(data)
%etimate mean
mu = mean(data,1);
%deman
cdata = data-mu;

N = size(cdata,2);
coskew = zeros(N,N*N);
for i= 1:N
    for j=1:N
        for k=1:N
            coskew(j,N*(i-1)+k) = mean(cdata(:,i).*cdata(:,j).*cdata(:,k));
        end
    end
end