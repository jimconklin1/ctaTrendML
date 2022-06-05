%The output of this function should be exactly the same as what comes out
%of loadRapcFactors, except loadRapcFactorsFromLib loads from factor
%library (a collection of CSVs on disk).
% With one exception: we removed a few factors that are not currently used 
% in RAPC to make code easeier to understand.
function [ret] = loadRapcFactorsFromLib(pth)
    fctrList = {'MSCIworld', 'Markit IG CDX NA', 'BarcGlobalTreas', 'US Agency MBS' ... 
        , 'msQuality', 'msValue', 'msMomentum', 'msLowBeta' ...
        , 'HFRX', 'HFRX Equity', 'HFRX Event', 'HFRX CTA Macro' ...
        , 'USD LIBOR 3M', 'HFRX EMN' ...
    };

    fRaw = loadFactors(fctrList, pth);
    f = rawFctrListToOurTs(fRaw);
    [~, ret] = splitTimeSeries(f, datenum(isoStrToDate('2012-07-01')));
end

