function ret = getMonthStr(h, suff)
if ~exist('suff', 'var')
    suff = "mo";
end %if
if h <=0 
    ret = "Full";
else
    ret = string(num2str(h, '%02.f')) + suff;
end % if

end % function