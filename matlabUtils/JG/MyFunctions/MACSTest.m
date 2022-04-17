a=zeros(10,3,4);
aa=a;
b1=rand(10,3);
b2=-ones(10,3);
b3=ones(10,3);
a(:,:,1)=b1;
a(:,:,2)=b2;
a(:,:,3)=b3;

jSlice=zeros(10,1);
j=1;
for u=1:3
    jSlice = [jSlice, a(:,j,u)];
end
jSlice(:,1)=[];
sumj = sum(jSlice, 2);

aa(:,:,3)=a(:,:,1);
FastLookback = [1, 1, 1,  2,  2,  3,  3,  3,  3,  5,  5,  5,  13, 13,  21, 21,  21];
SlowLookback = [5, 8, 13, 8,  13, 13, 21, 34, 55, 21, 34, 55, 55, 89,  89, 144, 233];   
FastLookback = [1, 1, 1,  2, 2,  3,  3,  3,  3,  5,  5,  5,  8,  8,  13, 13,  13,  21, 21,  21];
SlowLookback = [5, 8, 13, 8, 13, 13, 21, 34, 55, 21, 34, 55, 34, 55, 55, 89,  144, 89, 144, 233]; 
FastLookback = [1,  3,  3,  5,  5,  13, 13,  21, 21];
SlowLookback = [13, 21, 34, 21, 34, 55, 89,  89, 144];
FastLookback = [1,  3,  5,   13,  21,  21,  21,  34];
SlowLookback = [13, 34, 21,  55,  89,  144, 233,  377];
macs = MACSFunction(x, 'ema', FastLookback, SlowLookback, 'no');
macs = MACSFunction(x, 'exp', FastLookback, SlowLookback)
macs = BOFunction(x, FastLookback, SlowLookback, 'no');