% Load factors from factor library
% Inputs:
% fctrNames - a list of character strings with factor names to load
% inPath - path on disk to load the factors from
% Output:
% an array of factors
function ret = loadFactors(fctrNames, inPath)
    sz = length(fctrNames);
    ret = repelem(struct(),sz);
    for i = 1:sz
        fctrName = fctrNames{i};
        ret(i).name = fctrName;
        try
            fn = fullfile(inPath, [fctrName '.json']);
            ret(i).ref = fromJsonFile(fn);
            fn = fullfile(inPath, [fctrName '.csv']);
            ret(i).return = readtable(fn, 'PreserveVariableNames', true ...
                , 'Format', '%{MM/dd/yyyy}D %f', 'Delimiter', ',', 'HeaderLines', 0 ...
                , 'ReadVariableNames', true);
        catch ME
            if strcmp(ME.identifier, 'MATLAB:FileIO:InvalidFid')
                % Had to escape the backslash often found in file paths
                throw(MException('Data:Missing' ...
                    , sprintf('Factor file not found: %s', strrep(fn, '\', '\\'))));
            else
              rethrow ME;
            end 
        end % try;
        
    end % i
    
end

