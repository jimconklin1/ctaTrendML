
addpath('C:\GIT\utils_ml\_data')
bbgTickers = {'LT31TRUU Index','I18286US Index','NDDUWI Index','ERIXCDIG Index','US0003M Index'};
% 2-sigma case: 
% bbgTickers = {'LT31TRUU Index','I18286US Index','NDDUWI Index','ERIXCDIG Index'};
startDate = datenum('05dec2007'); 
endDate = busdate(today(),-1); 
bbgFields = {'PX_LAST'};
c = blp; 
freq = {'daily'};
[pxData, ~] = fetchBbgData(bbgTickers,bbgFields,c,startDate,endDate,freq);
[wDates,wRtns] = daily2weeklyRtns(pxData.dates,pxData.PX_LAST(:,1:4),'lvls','wed');
wRtns(:,5) = pxData.PX_LAST(:,5)/(100*52); % convert annual percentage rates into weekly returns for 3mo LIBOR
corrcoef(wRtns(2:end,:))

% options: in-sample (requires start and end dates) or out-of-sample.
opt.factorOpt = 'PubEq'; % 'PubEq', 'SAA', '2sigma'
opt.mode = 'insmpl'; %'insmpl'; 'oosmpl'l
opt.smplStart = NaN;
opt.smplEnd = NaN;

t1 = find(wDates(2:end,:)>=datenum('29dec2010'),1,'first'); 
switch opt.factorOpt
    case 'PubEq'
        if strcmp(opt.mode,'insmpl')
           X0 = wRtns(2:end,[3,1,4]); % 3 factors w/ sequence equities, rates, then credit
           disp('raw correlation matrix:'); 
           corrcoef(X0)
           corrcoef(X0(1:t1,:))
           corrcoef(X0(t1+1:end,:))
           X1 = nan(size(X0));
           XX1 = nan(size(X0));
           X1(:,1) = X0(:,1); 
           XX1(:,1) = X0(:,1); % non-demeaned
           % strip equities out of rates:
           y = X0(:,2); 
           X = X0(:,1);
           stats1 = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
           tt1 = array2table([stats1.tstat.beta'; stats1.tstat.t'; [stats1.rsquare,stats1.fstat.pval]],'RowNames',{'coeff';'t-stat';'Rsqr/pval'},'VariableNames',{'alpha','beta'});
           X1(:,2) = stats1.r;
           XX1(:,2) = stats1.r + stats1.tstat.beta(1); % non-demeaned
           % strip equities, rates out of credit:
           y = X0(:,3); 
           X = X1(:,1:2);
           stats2 = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
           tt2 = array2table([stats2.tstat.beta'; stats2.tstat.t'; [stats2.rsquare,stats2.fstat.pval,NaN]],'RowNames',{'coeff';'t-stat';'Rsqr/pval'},'VariableNames',{'alpha','beta1','beta2'});
           X1(:,3) = stats2.r;
           XX1(:,3) = stats2.r + stats2.tstat.beta(1); % non-demeaned
           disp('orthogonal correlation matrix:'); corrcoef(X1)
           % print formatted regression results here: 
           tt1 %#ok<NOPTS> 
           tt2 %#ok<NOPTS> 
           disp()
        elseif strcmp(opt.mode,'oosmpl')
           opt.oosHL = [6,104]; % OOS half-lives for WEEKLY DATA
           opt.oosBuffer = [6,104]; % regression buffer in WEEKS
           % etc. 
        end 
        figure(1); plot(wDates(2:end,:),calcCum([X0(:,1),XX1(:,1)],1));
        grid; datetick('x','mmmyyyy'); legend({'equitiesRaw','equitiesOrth'})
        figure(2); plot(wDates(2:end,:),calcCum([X0(:,2),XX1(:,2)],1));
        grid; datetick('x','mmmyyyy'); legend({'ratesRaw','ratesOrth'})
        figure(3); plot(wDates(2:end,:),calcCum([X0(:,3),XX1(:,3)],1));
        grid; datetick('x','mmmyyyy'); legend({'kreditRaw','kreditOrth'})
    case 'SAA'
        if strcmp(opt.mode,'insmpl')
           X0 = wRtns(2:end,[2,1,3:4]); % 4 factors w/ sequence real rates, inflation, equities, then credit
           X0(:,2) = wRtns(2:end,1)-wRtns(2:end,2); % inflation returns = nominal rate returns - real rate returns
           X1 = nan(size(X0));
           X1(:,1:2) = X0(:,1:2); 
           % strip inflation, real rates out of equities:
           y = X0(:,3); 
           X = X0(:,1:2);
           stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
           X1(:,3) = stats.r;
           % strip equities, rates out of credit:
           y = X0(:,4); 
           X = X1(:,1:3);
           stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
           X1(:,4) = stats.r;
        elseif strcmp(opt.mode,'oosmpl')
           opt.oosHL = [6,104]; % OOS half-lives for WEEKLY DATA
           opt.oosBuffer = [6,104]; % regression buffer in WEEKS
           % etc. 
        end 
    case '2sigma'
        if strcmp(opt.mode,'insmpl')
            X0 = wRtns(2:end,[2,1,3:4]); % 4 factors w/ sequence real rates, inflation, equities, then credit        
        elseif strcmp(opt.mode,'oosmpl')
           opt.oosHL = [6,104]; % OOS half-lives for WEEKLY DATA
           opt.oosBuffer = [6,104]; % regression buffer in WEEKS
           % etc. 
        end 
end

