function[slope, intercept, resid] = SlopeIntercept(x,Lookback,method)
%
%__________________________________________________________________________
%
% This code compute the meaningful statistical trend on a rolling basis
% Input: -  x        = Asset Price
%        -  Lokkback = Lookback period
% Output: - slope      = slope
%         - intercept   statistical signification (look for abs(smt)>2.5
%__________________________________________________________________________
%
%
% -- Prelocate Matrix --
[nsteps,ncols]=size(x);
intercept = zeros(size(x));
slope = zeros(size(x)); 
resid = zeros(size(x));
%
% -- Set Time vector --
TimeTrend=(1:1:Lookback);
ct=ones(Lookback,1);
% -- Run Loop --
for j=1:ncols
    % .. Identify Start ..
    start_date(1,1)=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j)) && x(i,j)~=0
            start_date(1,1)=i;
            break
        end
    end 
    % .. Run Model ..
    for i=start_date(1,1)+Lookback:nsteps
        MyX=x(i-Lookback+1:i,j);
        switch method
            case {'gross'}
            NormMyX = MyX;
            case {'rebase'}
            NormMyX = MyX ./ repmat(MyX(1,1),length(MyX),1);
            case {'log', 'ln', 'natural log'}
            NormMyX = log(MyX);
        end
        [b, ~ , r] = regress(NormMyX , [ct , TimeTrend']); 
        intercept(i,j) = b(1,1);
        slope(i,j) = b(2,1);
        resid(i,j) = r(length(r),1);
    end
end
