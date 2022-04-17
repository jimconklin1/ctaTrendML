%
% a test example of the Hill estimator code
%
%

clear;

rand('state', 2);

N = 10000;
M = 1;
alpha = 1.2;
b = 3;
X = randp(N,M,alpha,b);
x = b:max(X)/1000:max(X);

% plot the CCDF of the data against the theoretical curve on a log-log graph
figure(1)
subplot(1,2,1)
hold off
p1 = loglog(sort(X), 1-(1:N)/N, 'b');
hold on
p2 = plot(x, (b./x).^(alpha), 'r--');
title('distribution function');
xlabel('x');
ylabel('1-F(x)');
legend([p1 p2], 'data', 'theoretical');

% plot an approximation of the density of the data against the theoretical curve on a log-log graph
figure(1)
subplot(1,2,2)
hold off
p2 = loglog(x, (alpha/b) * (b./x).^(alpha+1), 'r--');
hold on
[y, x] = hist(X, 1000);
temp = diff(x);
p1 = plot(x, y/N/temp(1));
title('density');
xlabel('x');
ylabel('f(x)');
legend([p1 p2], 'data', 'theoretical');

set(gcf, 'PaperPosition', [0 0 6 3]);
print('-dtiff', 'randp_test.tiff');
unix('convert randp_test.tiff randp_test.png');
% print('-depsc', 'randp_test.eps');

