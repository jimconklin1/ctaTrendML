function [str] = numFormat(num, fmt)
    try
        if ~exist('fmt','var')
            fmt = '####################.####';
        end
        str = char(java.text.DecimalFormat(fmt).format(num));
    catch
        str = 'ERR';
    end    
end

