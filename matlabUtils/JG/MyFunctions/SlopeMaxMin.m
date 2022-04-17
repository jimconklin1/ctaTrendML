function[MaxX, MinX, bMax, bMin] = SlopeMaxMin(x,MinMaxPeriod)
%
%__________________________________________________________________________
%
% This code compute the meaningful statistical trend on a rolling basis
% Input: - x        = Asset Price
%        - Lokkback = Lookback period
% Output: - smb = slope
%         - smt = statistical signification (look for abs(smt)>2.5
%__________________________________________________________________________
%
%
% -- Prelocate Matrix --
[nsteps,ncols]=size(x);
MaxX=zeros(size(x)); bMax=zeros(size(x));
MinX=zeros(size(x)); bMin=zeros(size(x));
%
%
for j=1:ncols
    % -- Identify Start --
    start_date(1,1)=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j)) && x(i,j)~=0
            start_date(1,1)=i;
            break
        end
    end 
    % -- Identify Max & Min --
    for i=start_date(1,1)+MinMaxPeriod:nsteps
        MaxX(i,j)=max(x(i-MinMaxPeriod+1:i,j));
        MinX(i,j)=min(x(i-MinMaxPeriod+1:i,j));
    end
    % -- Run Model --
    MinStartPeriod=10; % Minimum Period to start with
    for i=start_date(1,1)+MinMaxPeriod+MinStartPeriod:nsteps
        LengthVector = i - (start_date(1,1)+MinMaxPeriod) + 1;
        TimeTrend=(1:1:LengthVector)';
        % .. Slope for Max ..
        bmax = robustfit(TimeTrend,MaxX(start_date(1,1)+MinMaxPeriod:i,j)); 
        % .. Slope for Min ..
        bmin = robustfit(TimeTrend,MinX(start_date(1,1)+MinMaxPeriod:i,j)); 
        % .. Assign ..
        bMax(i,j)=bmax(2,1);bMin(i,j)=bmin(2,1);
    end
end
