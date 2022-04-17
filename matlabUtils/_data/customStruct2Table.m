function tbl = customStruct2Table(s, headered_list, inc_list, excl_list )
%converts a custom struct into a flat table
%the struct:
%  - MUST contain a 'dates' field which becomes the first column called timestamp (as required by TSRP)
%  - MAY contain a 'header' field as a cell array of strings
%  - MAY contain matrix fields with columns corresponsing to 'header'
%
%The function will flatten all matrix fields in the headered_list param
%into separate columns. It will also attach any other matrices to the
%returned table.
%
%inc_list and exc_list are lists of regular expressions which may be
%included or excluded. To include everything, pass {'.*'} as inc_list

    excl_list = [excl_list 'header' 'dates'];
    mtx = s.dates;
    
    fields = fieldnames(s);
    header = {'timestamp'};
    for x = 1:length(fields)
        fn = fields{x};
        
        %skip non-numeric fields
        if ~isnumeric(s.(fn)); continue; end
        
        %loop over each column of this field
        fsize = size(s.(fn));
        for fx = 1:fsize(2)

            if ~isempty(find(strcmp(fn, headered_list), 1))
                fnn = strcat(lower(fn),'_',lower(strrep(s.header{1,fx}, ' ', '_')));
            else
                fnn = fn;
            end
            
            %if the field name matches any of the regexp-s in the exclude list,
            %exclude it (no matter the include list)
            exclude = false;
            for e = 1:length(excl_list)
                if ~isempty(regexp(fnn, excl_list{e}, 'once'))
                    exclude = true;
                    break;
                end
            end
            if exclude; continue; end

            %check if the field name is on the include list
            include = false;
            for i = 1:length(inc_list)
                if ~isempty(regexp(fnn, inc_list{i}, 'once'))
                    include = true;
                    break;
                end
            end
        
            %if on the include list, append to the included list
            if include
                mtx = [mtx s.(fn)(:,fx)];
                header = [header fnn];
            end
        end
    end
    tbl = array2table(mtx, 'VariableNames', header);
end

