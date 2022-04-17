function srAddPaths()
%SRADDPATHS Adds all Matlab paths (single place to define them)

if (~isdeployed)
    addpath('H:\GIT\mtsrp\') 
    addpath(genpath('H:\GIT\matlabUtils\'))
end

end

