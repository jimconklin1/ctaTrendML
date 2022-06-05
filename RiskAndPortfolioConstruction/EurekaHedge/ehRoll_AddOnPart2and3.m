%Add on script for Parts 2 and 3 of Assignment

%Funds we want this quarter
AlphaSrp12Filter = (calc.pAlphaSrp_12mo >= -0.25); %Create filter for 12 month Alpha Srp
FundsInPortfolio = false(1, sz(2)); %1 row of falses to be used in first iteration of for loop as part of the FundsToBuy and FundsToSell variables.

FundsSold = false(sz);  
FundsBought = false(sz);
FundsPosition = false(sz);

%Empty cell arrays for the individual variables that will be populated later
varFundsBought = {};
varFundsSold = {};
varFundsPosition = {};

i0 = find(dates>=datenum('31-Mar-2016'),1); 
for i = i0:sz(1)
    FundsWeWant = AlphaSrp12Filter(i,:) & CombinedFilter(i, :); %At each quarter, identify funds we want based on universe and Alpha Srp 12
    lookbackPeriodStart = max(1, i-6); %This variable calculates the starting value for lookback period
    SoldByQuarter = FundsSold(lookbackPeriodStart:i-1, :); %Looks back at up to 6 prior quarters to determine whether fund has been sold in that time
    SoldRecently = any(SoldByQuarter, 1); %any() function collapses the prior periods to determine if fund was sold in any of those periods
    FundsToBuy = FundsWeWant & ~FundsInPortfolio & ~SoldRecently; %If we want the fund, it's not already in our portfolio, and we didn't sell recently then we will buy. FundsInPortfolio began with a row of falses.
    FundsToSell = ~FundsWeWant & FundsInPortfolio; %If we don't want the fund and the fund is in our portfolio, then we sell. Funds we don't want would be funds not in universe and funds with Alpha Srp 12 <-.25 or Nan.
    
    FundsInPortfolio = (FundsInPortfolio | FundsToBuy) & ~FundsToSell; %If the fund is in portfolio already or we buy the fund AND we don't want to sell, then place fund in portfolio
    FundsSold(i, :) = FundsToSell; 
    FundsBought(i, :) = FundsToBuy;
    FundsPosition(i, :) = FundsInPortfolio;
    
    
    %Output for Funds Bought
    FinalOutput2(1,:)=FundsBought(i,:);
    tFinalOutput2=array2table(FinalOutput2','VariableNames',{'FundsBought'});
    tFinalOutput2 = addvars(tFinalOutput2, dbData.geoMandate.funds', 'NewVariableNames', 'GeoMandate','Before','FundsBought');
    tFinalOutput2 = addvars(tFinalOutput2, dbData.style.funds', 'NewVariableNames', 'FundStyle','Before','GeoMandate');
    tFinalOutput2=addvars(tFinalOutput2,dbData.equHFrtns.header','NewVariableNames','FundName','Before','FundStyle');
    tFinalOutput2=addvars(tFinalOutput2,dbData.fundIdHeader','NewVariableNames','FundID','Before','FundName');
    tFilteredOutput2=tFinalOutput2(FundsBought(i,:),:); 
    
    %Output for Funds Sold
    FinalOutput3(1,:)=FundsSold(i,:);
    tFinalOutput3=array2table(FinalOutput3','VariableNames',{'FundsSold'});
    tFinalOutput3 = addvars(tFinalOutput3, dbData.geoMandate.funds', 'NewVariableNames', 'GeoMandate','Before','FundsSold');
    tFinalOutput3 = addvars(tFinalOutput3, dbData.style.funds', 'NewVariableNames', 'FundStyle','Before','GeoMandate');
    tFinalOutput3=addvars(tFinalOutput3,dbData.equHFrtns.header','NewVariableNames','FundName','Before','FundStyle');
    tFinalOutput3=addvars(tFinalOutput3,dbData.fundIdHeader','NewVariableNames','FundID','Before','FundName');
    tFilteredOutput3=tFinalOutput3(FundsSold(i,:),:); 

    %Output for Funds Position
    FinalOutput4(1,:)=FundsPosition(i,:);
    tFinalOutput4=array2table(FinalOutput4','VariableNames',{'FundsPosition'});
    tFinalOutput4 = addvars(tFinalOutput4, dbData.geoMandate.funds', 'NewVariableNames', 'GeoMandate','Before','FundsPosition');
    tFinalOutput4 = addvars(tFinalOutput4, dbData.style.funds', 'NewVariableNames', 'FundStyle','Before','GeoMandate');
    tFinalOutput4=addvars(tFinalOutput4,dbData.equHFrtns.header','NewVariableNames','FundName','Before','FundStyle');
    tFinalOutput4=addvars(tFinalOutput4,dbData.fundIdHeader','NewVariableNames','FundID','Before','FundName');
    tFilteredOutput4=tFinalOutput4(FundsPosition(i,:),:); 
    
    %Combined Variable
    varForJim{3,i+1}=tFilteredOutput2;
    varForJim{4,i+1}=tFilteredOutput3;
    varForJim{5,i+1}=tFilteredOutput4;
    varForJim{3,1} = "FundsBought";
    varForJim{4,1} = "FundsSold";
    varForJim{5,1} = "FundsPosition";
    
    %Individual Variables
    varFundsBought{i} = tFilteredOutput2;
    varFundsSold{i} = tFilteredOutput3;
    varFundsPosition{i} = tFilteredOutput4;
end %for i

fundOfFundsPnL = FundsPosition.*calc.hfTtlRtn;
fofPnLcum = calcCum(sum(fundOfFundsPnL,2),1);
plot(fofPnLcum)
