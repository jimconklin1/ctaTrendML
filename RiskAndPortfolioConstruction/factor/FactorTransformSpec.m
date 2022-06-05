classdef FactorTransformSpec
    %FACTORCFGITEM Defines transfomation rules for a given factor
    
    properties
        name = '';
        riskFreeStripped = false;
        canStripRiskFree = true;
        orth = {};
        volScale = '';
    end
    
    methods(Static)
        function ret = fromStruct(s)
            ret = FactorTransformSpec;
            for f = string(fields(s))'
                ret.(f) = s.(f);
            end % for
            
        end % funciton fromStruct
    end %methods 
end

