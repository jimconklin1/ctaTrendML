function ret = filterLmCoeffs(lm, rExp)

flt = regexp(lm.Coefficients.Properties.RowNames, rExp);
flt = cellfun(@(x) isempty(x), flt);
ret = lm.Coefficients(flt, :);

end % function