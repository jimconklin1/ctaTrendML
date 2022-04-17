%function z = LogisticTransf(x,parameters)
x=sort(atr);
parameters=[0,1000, -10e-1 , 2];
y = parameters(1,1) + parameters(1,2) / ...
    (1+exp(parameters(1,3)*x+parameters(1,4)));
y=y';
plot(x,y)
[max(y), min(y), mean(y)]