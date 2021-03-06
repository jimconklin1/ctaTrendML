function [r,t,p]=spear(x,y)


%Syntax: [r,t,p]=spear(x,y)
%__________________________
%
% Spearman's rank correalation coefficient.
%
% r is the Spearman's rank correlation coefficient.
% t is the t-ratio of r.
% p is the corresponding p-value.
% x is the first data series (column).
% y is the second data series, a matrix which may contain one or multiple
%     columns.

% Example:
% x = [1 2 3 3 3]';
% y = [1 2 2 4 3; rand(1,5)]';
% [r,t,p] = spear(x,y)
%
%
% Products Required:
% Statistics Toolbox
%

% x and y must have equal number of rows
if size(x,1)~=size(y,1)
    error('x and y must have equal number of rows.');
end

% Find the data length
N = length(x);

% Get the ranks of x
R = crank(x)';

for i=1:size(y,2)
    
    % Get the ranks of y
    S = crank(y(:,i))';
    
    % Calculate the correlation coefficient
    r(i) = 1-6*sum((R-S).^2)/N/(N^2-1);
    
end

% Calculate the t statistic
if r == 1 || r == -1
    t = r*inf;
else
    t=r.*sqrt((N-2)./(1-r.^2));
end

% Calculate the p-values
p=2*(1-tcdf(abs(t),N-2));


function r=crank(x)
%Syntax: r=crank(x)
%__________________
%
% Assigns ranks on a data series x. 
%
% r is the vector of the ranks
% x is the data series. It must be sorted.

u = unique(x);
[xs,z1] = sort(x);
[z1,z2] = sort(z1);
r = (1:length(x))';
r=r(z2);

for i=1:length(u)
    
    s=find(u(i)==x);
    
    r(s,1) = mean(r(s));
    
end