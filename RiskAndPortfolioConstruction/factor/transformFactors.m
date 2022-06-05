% Applies factor transformations according to config.
% Inputs:
% fctrRtns - factor returns in RAPC format
% cfg - object of type FactorTransformCfg, configuration for factor transformations
% riskFreeFctrName - facrtor name for "risk free" rate
function ret = transformFactors(fctrRtns, cfg, riskFreeFctrName)

    ret = fctrRtns;
    rfr = fctrRtns.values(:, strcmp(riskFreeFctrName, fctrRtns.header));
    
    for i = 1:length(fctrRtns.header)
        fctrName = fctrRtns.header{i};
        fCfg = cfg.getItem(fctrName);
        if fCfg.riskFreeStripped
            fctrRtns.values(:, i) = fctrRtns.values(:, i) - rfr;
        end % if
    end % for
    
    for i = 1:length(fctrRtns.header)
        fctrName = fctrRtns.header{i};
        fCfg = cfg.getItem(fctrName);
        % Make a copy on each iteration to make sure iterations don't
        % affect each other
        fctrCopy = fctrRtns.values;

        if ~isempty(fCfg.orth)
            x = orthogonalizeFactor(fctrCopy, fctrRtns.header, {fctrName}, fCfg.orth, 'InSample', false);
        else
            x = fctrCopy(:, i);
        end % if orth
        
        if fCfg.volScale
            volScaleFctrRtns = fctrCopy(:, strcmp(fCfg.volScale, fctrRtns.header));
            x = x * nanstd(volScaleFctrRtns) / nanstd(x);
        end % if volScale
        
        ret.values(:, i) = x;

    end % for
    
    
end

