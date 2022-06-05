function orthogonalFactors = OrthogonalizeRiskFactors(factorNames, rawFactorReturns)

orthogonalFactors = rawFactorReturns;

%Real Rates
X= [orthogonalFactors(:,factorNames == "Equity")];
stats = regstats(rawFactorReturns(:,factorNames == "RealRates"),X,"Linear","r");
orthogonalFactors(:,factorNames == "RealRates") = stats.r;

%Inflation
orthogonalFactors(:,factorNames == "NominalRates") = rawFactorReturns(:,factorNames == "NominalRates") - rawFactorReturns(:,factorNames == "RealRates");
factorNames(factorNames == "NominalRates") = cellstr("Inflation");

%Kredit
X= [orthogonalFactors(:,factorNames == "Equity"),orthogonalFactors(:,factorNames == "RealRates"),orthogonalFactors(:,factorNames == "Inflation")];
stats = regstats(rawFactorReturns(:,factorNames == "Credit"),X,"Linear","r");
orthogonalFactors(:,factorNames == "Credit") = stats.r;

%Mortgage
X= [orthogonalFactors(:,factorNames == "RealRates"),orthogonalFactors(:,factorNames == "Inflation")];
stats = regstats(rawFactorReturns(:,factorNames == "Mortgage"),X,"Linear","r");
orthogonalFactors(:,factorNames == "Mortgage") = stats.r;