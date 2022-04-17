function downtest = DowntestFunction(c,ema13,k8)

downtest = zeros(size(c));
[nsteps,ncols]=size(c);
for i=10:nsteps  
    for j=1:ncols
        if k8(i-1,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;
        elseif k8(i-2,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;
        elseif k8(i-3,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;     
        elseif k8(i-4,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;  
        elseif k8(i-5,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;   
        elseif k8(i-6,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;     
        elseif k8(i-7,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;  
        elseif k8(i-8,j) > 90 && c(i,j) < ema13(i,j)
            downtest(i,j) = downtest(i,j)-1;      
        end
    end
end
            