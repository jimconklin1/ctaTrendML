function[equi, stime, s13, s21, s34, s55, s89, s144, s233] = Xreg2(x,ema13,ema21,ema34,ema55,ema89,ema144,ema233,Lookback)
%
%__________________________________________________________________________
%
% This code compute the meaningful statistical trend on a rolling basis
% Input: -  x        = Asset Price
%        -  Lokkback = Lookback period
% Output: - smb      = slope
%         - smt      = statistical signification (look for abs(smt)>2.5
%__________________________________________________________________________
%
%
% -- Prelocate Matrix --
[nsteps,ncols]=size(x);
equi=zeros(size(x));   stime=zeros(size(x));
s5=zeros(size(x));     s8=zeros(size(x));   s13=zeros(size(x));
s21=zeros(size(x));    s34=zeros(size(x));  s55=zeros(size(x));
s89=zeros(size(x));    s144=zeros(size(x)); s233=zeros(size(x));
%
% -- Set Time vector --
TimeTrend = (1:1:Lookback)';
cte = ones(Lookback,1);
% -- Run Loop --
for j=1:ncols
    % .. Identify Start ..
    start_date(1,1)=zeros(1,1);
    for i=1:nsteps
        if ~isnan(ema233(i,j)) && ema233(i,j)~=0
            start_date(1,1)=i;
            break
        end
    end 
    % .. Run Model ..
    for i=start_date(1,1)+Lookback:nsteps
        MyX=x(i-Lookback+1:i,j);
        Myendo = [ TimeTrend, ema13(i-Lookback+1:i,j), ...
            ema21(i-Lookback+1:i,j), ema34(i-Lookback+1:i,j), ema55(i-Lookback+1:i,j), ...
           ema89(i-Lookback+1:i,j), ema144(i-Lookback+1:i,j), ema233(i-Lookback+1:i,j)];
       
        b = regress(MyX, Myendo); 
        myeq = b' * Myendo(size(Myendo,1),:)';
       stime(i,j) = b(1,1);
       s13(i,j) = b(2,1);   s21(i,j) = b(3,1);
       s34(i,j) = b(4,1);   s55(i,j) = b(5,1);
       s89(i,j) = b(6,1);   s144(i,j) = b(7,1);
       s233(i,j) = b(8,1);
        equi(i,j)=myeq;
    end
end
