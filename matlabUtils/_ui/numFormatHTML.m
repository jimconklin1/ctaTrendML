function [str] = numFormatHTML(num)
    str = char(java.text.DecimalFormat('##,###,###,###,###,###,###.####;''<span style=\"color:#CC0000\">''(##,###,###,###,###,###,###.####)''</span>''').format(num));    
end

