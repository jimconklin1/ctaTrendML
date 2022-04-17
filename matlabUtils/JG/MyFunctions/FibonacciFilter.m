function y = FibonacciFilter(x,Lookback)
%--------------------------------------------------------------------------
%
%Lookback=10;
%--------------------------------------------------------------------------
%
% Identify Dimension
[nsteps,ncols]=size(x);
% Prelocate Matric
y=zeros(size(x));
%
% Load Fibonacci
load FibonacciSeries
%
% Look for Last Data Point
FibStep=FibonacciSeries(Lookback+1,1);
%
FibMax=FibonacciSeries(2*(Lookback+1),2);
% Build lag Structure
LagStructure=zeros(Lookback,1);
for i=1:Lookback
    LagStructure(i)=2*i-1;
end
% Get lagged Fibonacci
FibLagged=zeros(Lookback,1);
for i=1:Lookback
    FibLagged(i)=FibonacciSeries(2*(Lookback+1)-LagStructure(i),2);
end
% Fibonacci-based Weights
FiboWgt=FibLagged ./ repmat(FibMax,Lookback,1);
FlipFiboWgt=flipud(FiboWgt);
%
clear FibonacciSeries
%
% Run Filter
for j=1:ncols
    % Identify first date
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Fibonacci-based filter
    for i=start_date(1,1)+Lookback+1:nsteps
        % Extract
        xlag=x(i-Lookback+1:i,j);
        y(i,j)=sum(FlipFiboWgt .* xlag);
    end
end