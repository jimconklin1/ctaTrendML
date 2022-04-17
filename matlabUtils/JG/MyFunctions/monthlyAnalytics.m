%
%__________________________________________________________________________
%
% Transform daily portoflio to monthly portoflio 
%__________________________________________________________________________
%

function georetMthTable = monthlyAnalytics(dateBench, dailyreturns)


% dimension & prelocate matrice
nsteps = size(dateBench,1);

% geopl
geopl = 100*ones(nsteps,1);
for i=2:nsteps, geopl(i) = geopl(i-1)*(1+dailyreturns(i)); end

%finalMonth = month(dateBench(nsteps));
finalYear = year(dateBench(nsteps));
starYear = year(dateBench(1));
yearsNb = finalYear - starYear;

geoPlMthTable = zeros(yearsNb, 12);
georetMthTable = zeros(size(geoPlMthTable));

for i=2:nsteps
    if month(dateBench(i)) ~= month(dateBench (i-1))
        colIdx = month(dateBench(i-1));
        rowIdx = year(dateBench(i-1)) - starYear + 1; 
        geoPlMthTable(rowIdx, colIdx) = geopl(i-1);
    end
end

% Janurary return
for i=2:yearsNb
    georetMthTable(i,1) = 100*(geoPlMthTable(i,1) / geoPlMthTable(i-1,12) - 1);
end
% other months returns
for i=2:yearsNb
    for j=2:12
        georetMthTable(i,j) = 100*(geoPlMthTable(i,j) / geoPlMthTable(i,j-1) - 1);
    end
end

