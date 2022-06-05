function o = preProcIlliquidFactorsInput(equFactorRtns, cfg)

if cfg.opt.autoTrimReturns
    maxDate = equFactorRtns.dates(1);
    startFIdx = find(equFactorRtns.dates == maxDate);
    
    if isempty(startFIdx)
        throw(MException('Data:Invalid' ...
            , 'Start Dates are not aligned between fund returns and factor returns.'));
    end % if
    
    equFactorRtns.dates = equFactorRtns.dates(startFIdx:end,:);
    equFactorRtns.values = equFactorRtns.values(startFIdx:end,:);
    
    minDate = min(equFactorRtns.dates(end));
    endFIdx = find(equFactorRtns.dates == minDate);
    
    if isempty(endFIdx)
        throw(MException('Data:Invalid' ...
            , 'End Dates are not aligned between fund returns and factor returns.'));
    end % if
    
    equFactorRtns.dates = equFactorRtns.dates(1:endFIdx,:);
    equFactorRtns.values = equFactorRtns.values(1:endFIdx,:);
    
end % if cfg.opt.autoTrimReturns
    
% HACKS: rendering market factors mutually orthogonal, and making them
%   excess returns:
mm = find(strcmp(cfg.headers.riskFree,equFactorRtns.header)); 
rfr = equFactorRtns.values(:,mm);  %#ok<FNDSB>
equFactorRtns.values(:,1) = equFactorRtns.values(:,1) - rfr; % render MSCI World ex-LIBOR
                                                             % credit is already ex-LIBOR
equFactorRtns.values(:,3) = equFactorRtns.values(:,3) - rfr; % render US Treasury Index ex-LIBOR
equFactorRtns.values(:,4) = equFactorRtns.values(:,4) - rfr; % render US Agency MBS ex-LIBOR
orth = orthogonalizeFactor(equFactorRtns.values,equFactorRtns.header,{'Markit IG CDX NA'},{'MSCIworld'},'InSample',false);
temp = nanstd(equFactorRtns.values(:,3))/nanstd(orth); % scale vol on credit factor to be the same as US treasuries
equFactorRtns.values(:,2) = temp*orth; % credit
orth = orthogonalizeFactor(equFactorRtns.values,equFactorRtns.header,{'US Agency MBS'},{'BarcGlobalTreas'},'InSample',false);
temp = nanstd(equFactorRtns.values(:,3))/nanstd(orth); % scale vol on MBS factor to be the same as US treasuries
equFactorRtns.values(:,4) = temp*orth; % mtg

% ad hoc what-if for Ric
%hackInd = mapStrings({'Voleon Investors','Voleon Inst', 'Winton Diversified', 'BW Pure Alpha 21 Vol'}, mktValue.header);
%zz1 = tempMktVal(hackInd);
%tempMktVal(hackInd) = [30000000, 90000000, 0,0];
%zStyle = mktValue.style(hackInd);
%zz2 = tempMktVal(hackInd);
%mktValue.values = zeros(size(mktValue.values));

% re-name factor variables, compute some params:
factors = equFactorRtns.values; 
fHeader = equFactorRtns.header;
volsFact = sqrt(12)*std(factors)';
t0 = 1;
tt0 = 1;

rfr = rfr(t0:end,:); 
factorRtns = factors(tt0:end,:); 
clear mm; 

o.fHeader = fHeader;
o.dates = equFactorRtns.dates(t0:end,:);  
o.factorRtns = factorRtns;
o.rfr = rfr;
o.volsFact = volsFact;
o.t0 = t0;
o.tt0 = tt0;

end 