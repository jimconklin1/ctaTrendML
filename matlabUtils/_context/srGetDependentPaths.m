function srGetDependentPaths(filename)
% Get a list of paths where dependent matlab code resides
% ex: srGetDependentPaths('signalRunner.m')
    srAddPaths();
    deps = matlab.codetools.requiredFilesAndProducts(filename);
    deppaths = {};
    for i = 1:size(deps,2)
        disp(deps{1,i});
        [pathstr,~,~] = fileparts(deps{1,i});
        deppaths{end+1} = pathstr; %#ok<AGROW>
    end
    disp('--- Paths ---');
    disp(unique(deppaths)')
end

