function generatePositioningReport(header, weights, pnl, config)

index = length(weights);
report_table = [cell2table(transpose(header), 'VariableNames', {'Asset'}),...
    array2table(transpose([weights(index, :); weights(index-5, :);...
    weights(index, :) - weights(index-5, :); sqrt(256) * std(pnl)]),...
    'VariableNames', {'T_Position', 'T_5_Position', 'Net_Trade', 'Asset_Ann_vol'})];
writetable(report_table, strcat(config.dataPath, 'PositioningReport.', datestr(now, 'yyyymmdd'), '.csv'), 'QuoteStrings', true);

end