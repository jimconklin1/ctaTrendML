%Load data from CSV files: systematic risk factors and private asset returns
RawDataTable = readtable("M:\PublicEquityQuant\illiquidityPremium\LiquidityFactorEstimationData.csv");
disp(RawDataTable.Properties.VariableNames);

dates = RawDataTable.Date;
monthlyRFReturns = RawDataTable{:,'RiskFree'};
monthlyPCReturns = RawDataTable{:,'PrivateCorp'};
monthlyPIReturns = RawDataTable{:,'PrivateInfra'};
monthlyPSReturns = RawDataTable{:,'PrivateStruc'};
quarterlyPEReturns = RawDataTable{:,'PrivateEquity'};

factorNames = {'Equity','RealRates','NominalRates','Credit','Mortgage'};
rawFactorReturns = RawDataTable{:,factorNames};

psBenchReturns = RawDataTable{:,'PrivateStrucBench'};
peBenchReturns = RawDataTable{:,'PrivateEquityBench'};
usCorpReturns = RawDataTable{:,'USCorporate'};

%Desmooth PE BO quarterly returns
%unsmoothPEReturns = DesmoothPrivateReturns(dates,quarterlyPEReturns,peBenchReturns,monthlyRFReturns,2);
params = EstimateDistLagPrivateReturns(dates,quarterlyPEReturns,peBenchReturns,monthlyRFReturns,2);
unsmoothPEReturns = DesmoothPrivateReturns(dates,quarterlyPEReturns,peBenchReturns,monthlyRFReturns,2);

%Interpolate unsmoothed PE BO quarterly returns
monthlyPEReturns = InterpolateQuarterlyReturns(dates,peBenchReturns,monthlyRFReturns,unsmoothPEReturns);

%Plot PE BO returns
figure
plot(dates(~isnan(quarterlyPEReturns)),quarterlyPEReturns(~isnan(quarterlyPEReturns)));
hold on
plot(dates(~isnan(unsmoothPEReturns)),unsmoothPEReturns(~isnan(unsmoothPEReturns)));
plot(dates,monthlyPEReturns);
plot(dates,peBenchReturns);
title('Unsmoothed/smoothed quarterly PE BO returns and monthly PE BO returns')
xlabel('Date');
ylabel('PE BO Returns')
legend({'Smoothed Quarterly','Unsmoothed Quarterly', 'Monthly','Benchmark'});

%Desmooth other private asset returns
figure
plot(dates,monthlyPCReturns);
monthlyPCReturns = DesmoothPrivateReturns(dates,monthlyPCReturns,psBenchReturns,monthlyRFReturns,3);
hold on
plot(dates,monthlyPCReturns);
plot(dates,psBenchReturns);
title('Unsmoothed/smoothed monthly private corporate returns')
xlabel('Date');
ylabel('Private Corp Returns')
legend({'Smoothed', 'Unsmoothed','Benchmark'});

figure
plot(dates,monthlyPIReturns);
monthlyPIReturns = DesmoothPrivateReturns(dates,monthlyPIReturns,psBenchReturns,monthlyRFReturns,3);
hold on
plot(dates,monthlyPIReturns);
plot(dates,psBenchReturns);
title('Unsmoothed/smoothed monthly private infrastructure returns')
xlabel('Date');
ylabel('Private Infra Returns')
legend({'Smoothed', 'Unsmoothed','Benchmark'});

figure
plot(dates,monthlyPSReturns);
monthlyPSReturns = DesmoothPrivateReturns(dates,monthlyPSReturns,psBenchReturns,monthlyRFReturns,3);
hold on
plot(dates,monthlyPSReturns);
plot(dates,psBenchReturns);
title('Unsmoothed/smoothed monthly private structured returns')
xlabel('Date');
ylabel('Private Structured Returns')
legend({'Smoothed', 'Unsmoothed','Benchmark'});
 
%Estimate liquidity factor
privateAssetReturns =[monthlyPCReturns, monthlyPIReturns, monthlyPSReturns, monthlyPEReturns];
orthogonalFactorReturns = OrthogonalizeRiskFactors(factorNames,rawFactorReturns);
useConstrainedPCA = false;
liquidityFactor = EstimateLiquidityFactor(privateAssetReturns,orthogonalFactorReturns,useConstrainedPCA);

%Plot
figure
plot(dates,liquidityFactor);
title('Empirical Liquidity Factor')
xlabel('Date');
ylabel('Liquidity Risk Premium')
