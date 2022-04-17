function[smb,smt, smbf,smtf] = SMTFunction(x,Lookback,pfast)
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
smb=zeros(size(x));
smt=zeros(size(x));
%
% -- Set Time vector --
TimeTrend=(1:1:Lookback);
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
        NormMyX=MyX ./ repmat(MyX(1,1),length(MyX),1);
        [b,stats] = robustfit(TimeTrend' , NormMyX); 
        smb(i,j)=b(2,1); smt(i,j)=stats.t(2,1);
    end
end
smbf=expmav(smb,pfast);smtf=expmav(smt,pfast);