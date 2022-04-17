%function[payfd , getfd] = ComputeDuration(SwapFixRate , Tenor, Settle)
%function[ModDuration,  YearDuration,  PerDuration] = ComputeDurationIRS(dirname, filename, aheetname, Yield, DateStamps, Period, Basis)
%
% -- Fetch Date in Corract Format to build N-year maturity
dirname = 'S:\00 Individuals\Joel\fixedincome\';
[tday, tdaynum, tday_txt, o,h,l,c] = UploadIRS(dirname, 'fixinc52', 'data');
Maturity = 10;
Period = 2;
Basis = 0;


% -- Dimensions & Parameters & Prelocate Matrices --
[nsteps,ncols] = size(c); 
dur=zeros(size(c));
% Solution 1
%ModDuration = zeros(size(c));     
%YearDuration = zeros(size(c));     
%PerDuration = zeros(size(c));
% Solution 2
payfd = zeros(size(c));     
getfd = zeros(size(c));

% -- Solution 1 --
for i = 1:nsteps%1: 1%length(tday_txt)
    % Rates
    Yield = c(i);  
    CouponRate = Yield;     
    % Settlement
    Settle_day = char(tday_txt(i));
    % Next days in Maturity years
    Maturity_day = addtodate(datenum(char(tday_txt(i))), Maturity, 'year');
    %check
    Maturity_day_str = datestr(Maturity_day, 'mm/dd/yyyy');
    [ModDuration,YearDuration,PerDuration]=bnddury(Yield,CouponRate, Settle_day, Maturity_day_str, Period, Basis);
    dur(i)=ModDuration;
end


% -- Solution 2 --
%SwapFixRate = 0.0383;
%Tenor = 1/365.25;
%Settle = tdaynum(nsteps,1);%datenum('11-Oct-2002');

%for i=1:nsteps
%    [PayFixDuration GetFixDuration] = liborduration(c(i)/100, Maturity, tdaynum(i));
%    payfd(i) = PayFixDuration;
%    getfd(i) = GetFixDuration;
%end


