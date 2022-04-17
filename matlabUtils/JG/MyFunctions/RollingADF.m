function [yc, yct, yc_check, yct_check] =  RollingADF(x,Period)
%
%--------------------------------------------------------------------------
% USAGE: results = adf(x,p,nlag)
% where:      x = a time-series vector
%             p = order of time polynomial in the null-hypothesis
%                 p = -1, no deterministic part
%                 p =  0, for constant term
%                 p =  1, for constant plus time-trend
%                 p >  1, for higher order polynomial
%         nlags = # of lagged changes of x included           
%--------------------------------------------------------------------------
%
% Prelocate matrix
[nrows,ncols]=size(x); 
yc=zeros(size(x));  
yct=zeros(size(x));
yc_check=zeros(size(x));  
yct_check=zeros(size(x));
%
adf_c_theo=[-3.75, -3.00;
             -3.58, -2.93;
             -3.51, -2.89;
             -3.46, -2.88;
             -3.44, -2.87;
             -3.43, -2.86];
adf_ct_theo=[-4.38, -3.60;
              -4.15, -3.50;
              -4.04, -3.45;
              -3.99, -3.43;
              -3.98, -3.42
              -3.96, -3.41];        
% Identify Row index in Empirical Cumulative Distribution of ADF
RowIndex=0;
if Period>=25 && Period<50
    RowIndex=1;
elseif Period>=50 && Period<100
    RowIndex=2;
elseif Period>=100 && Period<250
    RowIndex=3;
elseif Period>=250 && Period<500
    RowIndex=4;   
elseif Period>=500
    RowIndex=5; 
end
%    
for j=1:ncols
    % Identify Starting date
    start_date=zeros(1,1);
    for i=1:nrows
        if ~isnan(x(i,j)) && x(i,j)~=0
            start_date(1,1)=i;
        break
        end
    end    
    for i=start_date(1,1)+Period:nrows
        % Fetch vector
        Myx=x(i-Period+1:i,j);
        results_ct =  adf(Myx,0,1);
        results_ct_t =  adf(Myx,1,1);
        yc(i,j)=results_ct .adf;
        yct(i,j)=results_ct_t.adf;
        if abs(yc(i,j))>abs(adf_c_theo(RowIndex,2)),
            yc_check(i,j)=1;
        end
        if abs(yct(i,j))>abs(adf_ct_theo(RowIndex,2)),
            yct_check(i,j)=1;
        end        
    end
end
