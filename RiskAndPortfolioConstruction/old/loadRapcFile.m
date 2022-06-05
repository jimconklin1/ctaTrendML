function rapcInput = loadRapcFile(dataDir,dataSetName)
  fileName = fullfile(dataDir,dataSetName{1,1});
  rapcInput = load(fileName); % monthlyEquityARPandHFdata201812est.mat; varnames: equHFrtns equFactorRtns mktValue
  
  % TODO: remove trailing space in *.mat file: 'HFRX '
  hfrx_ind = find(strcmp({'HFRX '},rapcInput.equFactorRtns.header));
  rapcInput.equFactorRtns.header(hfrx_ind) = {'HFRX'};
  
end 