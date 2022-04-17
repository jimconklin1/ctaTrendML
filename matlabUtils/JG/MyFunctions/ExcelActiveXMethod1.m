excelObject = actxserver('Excel.Application');
filePattern = fullfile(myFolder, '*.xls');
xlsFiles = dir(filePattern);
for k = 1:length(xlsFiles)
  baseFileName = xlsFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  excelWorkbook = excelObject.workbooks.Open(fullFileName);
  worksheets = excelObject.sheets;
  numberOfSheets = worksheets.Count;
  for sheetIndex  = 1 : numberOfSheets 
    % Do whatever you want to do.
  end
end
excelObject.Quit;