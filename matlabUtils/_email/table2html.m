function html = table2html(tbl)
%TABLE2HTML Create an html string from a table object

%create the string builder and output the header
sb = java.lang.StringBuilder;
append(sb,'<table>');
append(sb,'<tr><td style="font-weight:bold; font-family: Arial;">');
append(sb,strjoin(tbl.Properties.VariableNames, '</td><td style="font-weight:bold; font-family: Arial;">'));
append(sb,'</td></tr>');

m = cellfun(@num2str,table2cell(tbl),'UniformOutput',0);

%stich together all pieces into a csv string
for r = 1:size(tbl,1)
    append(sb,'<tr>');
    for c = 1:size(tbl,2);
        append(sb,strcat('<td style="font-family: Arial;">', m{r,c}, '</td>'));
    end
    append(sb,'</tr>');
end
append(sb,'</table>');

html = char(toString(sb));
end

