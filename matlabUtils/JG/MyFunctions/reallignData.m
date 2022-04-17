%
%__________________________________________________________________________
%
%__________________________________________________________________________
%

function z = reallignData(dateBenchmark, dateVariable, xVariable)

nsteps = size(dateBenchmark,1);
nsteps_V = size(dateVariable,1);
z = nan(nsteps,1);
counter = 1;

for u=1:nsteps_V
    tgtDate = dateVariable(u);
    valueDate = xVariable(u);
    for i = counter:nsteps
        if tgtDate == dateBenchmark(i)
             z(i) = valueDate;
            break
        end
    end
    counter = counter+1;
end

for i=2:nsteps
    if isnan(z(i))
        z(i) = z(i-1);
    end
end

