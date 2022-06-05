% Converts a list of factors loaded from the factor library to a format
% consumable by RAPC.
function ret = rawFctrListToOurTs(rawFctrs)
    sz = length(rawFctrs);
    if sz <=0 
        throw(MException('Data:Missing', 'No factors found.'));
    end % if
    
    ret = struct();
    ret.values=[];
    ret.header = repmat({''},1,sz);
    ret.ids = NaN(1,sz);
    ret.dates=[];
    ret.bbgTicker = repmat({''},1,sz);

    
    for i = 1:sz
        fctr = rawFctrs(i);
        curTbl = fctr.return;
        curTbl.Properties.VariableNames(2) = {fctr.name};
        if i==1
            tsTbl = curTbl;
        else
            tsTbl = outerjoin(tsTbl, curTbl, 'MergeKeys',true);
        end % if 
        ret.ids(i) = fctr.ref.Id;
        ret.bbgTicker{i} = fctr.ref.identifiers.BBG_Ticker;
        ret.header{i} = fctr.name;
    end % i
    ret.values = table2array(tsTbl(:, 2:end));
    ret.dates = datenum(table2array(tsTbl(:,1)));
end

