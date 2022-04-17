function o = cdx_fetch_one(ids, gid, row_fmt, start_date, end_date, hasheader, url_extra)
import tsrp.*
global TSRP_CONF
if isempty(TSRP_CONF); tsrp.init(); end

gabbro = 'https://%s/%s/%s?start=%s&end=%s';
if exist('url_extra','var')
    gabbro = strcat(gabbro,'&',url_extra);
end
if ~exist('hasheader','var')
    hasheader = true;
end

host = get_host();
ids = lower(strrep(ids, ' ', '_'));
if isempty(row_fmt)
    hdr = '';
else
    hdr = strtrim(repmat('%s ',1,1+length(strsplit(row_fmt, ' '))));
end
%row = ['%{yyyy-MM-dd HH:mm:ss}D ' row_fmt];
row = ['%{yyyy-MM-dd}D ' row_fmt];

%get a cell for each id
ts = cellfun(@(id) cdx_csv_request(sprintf(gabbro,host,gid,id,start_date,end_date), hdr, row,hasheader, TSRP_CONF.user, TSRP_CONF.hash), ids, 'UniformOutput',false);

ret = table();
names = {};

%prepend each column after 'timestamp' with the id
for t = 1:length(ts)
    names = ts{1,t}.Properties.VariableNames;
    if length(ts) > 1
        ids = strrep(strtok(ids, '.'), '-', '_');
        ts{1,t}.Properties.VariableNames = strrep(cat(2, 'timestamp', strcat(ids{t}, names(2:length(names)))), '.', '_');
    end
    if ~isempty(ts{1,t})
        ret = ts{1,t}(:,1);
    end
end
    
if width(ret) == 0
    ret = table();
else
    for t = 1:length(ts)
        if ~isempty(ts{1,t})
            ret = outerjoin(ret, ts{1,t},'MergeKeys',true,'Keys',1);
        else
            empty = [ret(:,1) cell2table(repmat({NaN}, height(ret), length(names) - 1))];
            empty.Properties.VariableNames = ts{1,t}.Properties.VariableNames;
            ret = outerjoin(ret,empty,'MergeKeys',true,'Keys',1);
        end
    end
end

%At this point we have proper table, but the first column is not a datenum...
if isempty(ret)
    o = cell2table({});
else
    dn = table2cell(varfun(@datenum,ret(:,1))); %dn is a cell array of datenums
    o = cell2table([dn table2cell(ret(:,2:end))], 'VariableNames', ret.Properties.VariableNames);
end