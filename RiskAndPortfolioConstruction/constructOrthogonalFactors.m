
% Load raw factor data
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
wRates = pxData.PX_LAST(ismember(pxData.dates,wDates),5);
wRates = wRates/(100*52);% convert annual percentage rates into weekly returns for 3mo LIBOR
wRtns = [wRtns, wRates];
factorHeader = ["Nominal","Real","Equity","Credit","Libor3M"];

%clean NaN
nonNaNIdx = ~isnan(wRates);
nonNaNIdx(1)=0;
wDates=wDates(nonNaNIdx);
wRtns=wRtns(nonNaNIdx,:);

% options: in-sample (requires start and end dates) or out-of-sample.
opt.factorOpt = 'PubEq'; % {'PubEq', 'SAA', '2Sigma'}
opt.mode = 'OutOfSample'; % {'InSample', 'OutOfSample'}
opt.smplStart = NaN;
opt.smplEnd = NaN;

switch opt.factorOpt
    case 'PubEq'
        finalHeaders = ["Equity","Rates", "Kredit"];
        rawFactors = zeros(size(wRtns,1),3);
        rawFactors(:,1) = wRtns(:,3);
        rawFactors(:,2) = wRtns(:,1);
        rawFactors(:,3) = wRtns(:,4);
        orthFactors = zeros(size(wRtns,1),3);
        orthFactors(:,1) = wRtns(:,3);
        yr = orthogonalizeFactor(wRtns,factorHeader,"Nominal",["Equity"],opt.mode);
        orthFactors(:,2) = yr;
        yr = orthogonalizeFactor(wRtns,factorHeader,"Credit",["Equity","Nominal"],opt.mode);
        orthFactors(:,3) = yr;
    case 'SAA'
        wRtns(:,1) = wRtns(:,1)-wRtns(:,2);
        finalHeaders = ["Real","Inflation","Equity","Kredit"];
        rawFactors = zeros(size(wRtns,1),4);
        rawFactors(:,1) = wRtns(:,2);
        rawFactors(:,2) = wRtns(:,1);
        rawFactors(:,3) = wRtns(:,3);
        rawFactors(:,4) = wRtns(:,4);
        orthFactors = zeros(size(wRtns,1),4);
        orthFactors(:,1) = wRtns(:,2);
        orthFactors(:,2) = wRtns(:,1);
        factorHeader(1) = "Inflation";
        yr = orthogonalizeFactor(wRtns,factorHeader,"Equity",["Real","Inflation"],opt.mode);
        orthFactors(:,3) = yr;
        yr = orthogonalizeFactor(wRtns,factorHeader,"Credit",["Equity","Real","Inflation"],opt.mode);
        orthFactors(:,4) = yr;
    case '2Sigma'
end

disp('Orthogonal Correlation Matrix:');
disp(finalHeaders);
disp(corrcoef(orthFactors));

for i=1:size(finalHeaders,2)
    figure(i); plot(wDates(2:end,:),calcCum([rawFactors(2:end,i),orthFactors(2:end,i)],1));
    grid; datetick('x','mmmyyyy'); legend({finalHeaders(1,i)+"-Raw",finalHeaders(1,i)+"-Orth"})
end


