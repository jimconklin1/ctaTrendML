function params = setOptParams_VALIC(cfg)

params.RBCLimit = 0.6; % 0.4 is current value for all of L&R
params.ICLimit = 0.5; % 0.33 is current value for all of L&R
params.illiquidLimit = -999999999; % this will remove the constraint from the optimization; initial value if binding = 0.33
params.liquidationLimit = -999999999; % 
params.capCons = true; % true false % capacity constraints?

if strcmp(cfg.riskType,'Intrinsic')
    params.varianceTarget = (0.15^2); % in annual units
elseif strcmp(cfg.riskType,'Accounting')
    params.varianceTarget = (0.1^2); % in annual units
end

if strcmp(cfg.riskType,'Intrinsic')
    params.shrinkageRP = 1.0e-02; %2.1e-02; %0.02 is roughly parametrized to give this moderate but meaningful impact for i
else % 'Accounting'
    params.shrinkageRP = 1.0e-02;
end

end