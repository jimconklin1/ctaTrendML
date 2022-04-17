function o = cdx_tstable2csv(tbl)
import tsrp.*

%create the string builder and output the header
sb = java.lang.StringBuilder;
append(sb,strjoin(tbl.Properties.VariableNames, ','));
append(sb,char(10));

%size in variables for faster loops
nrows = size(tbl,1);
ncols = size(tbl,2);

ts = table2array(tbl(:,1:3));

try
    tbl = table2cell(tbl);
catch
    %ignore
end

%converting all datenums at once seems faster than doing it inside the output loop
ds = cellstr([datestr(ts(:,1)','yyyy-mm-dd,') datestr(ts(:,2)','yyyy-mm-dd HH:MM:SS,') datestr(ts(:,3)','yyyy-mm-dd HH:MM:SS,')]);

%stich together all pieces into a csv string
for r = 1:nrows
    append(sb,ds(r,1));
    for c = 4:ncols
        cell_value = tbl{r,c};
        if ~iscell(cell_value)
            if ~isnan((cell_value))
                append(sb,num2str(cell_value));
            end 
        else
            if iscellstr(cell_value)
                append(sb,strrep(cell_value, ',', ''));    
            else
                append(sb,cell_value{1});
            end
        end
        if c < ncols
            append(sb,',');
        end
    end
    append(sb,char(10));
end
if length(sb) > 0 %#ok<ISMT>
    deleteCharAt(sb,length(sb) - 1);
end

o = char(toString(sb));