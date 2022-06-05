classdef FactorTransformCfg
    %FACTORCFG A collection of factor transformation specs
    
    properties(GetAccess = private, SetAccess = private)
        map_ = containers.Map('KeyType','char','ValueType','any');
    end
    
    methods
        function ret = getItem(obj, factorName)
            if obj.map_.isKey(factorName)
                ret = obj.map_(factorName);
            else
                % Default factor config
                ret = FactorTransformSpec;
                ret.name = factorName;
            end %if
        end
        
        function ret = hasItem(obj, factorName)
            ret = obj.map_.isKey(factorName);
        end

        function ret = names(obj)
            ret = obj.map_.keys();
        end
        
        function addItem(obj, val)
            obj.map_(val.name) = val;
        end
    end
end

