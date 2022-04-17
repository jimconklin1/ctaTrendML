% --------------------------------------------------------------------
% DeleteEmptyExcelSheets: deletes all empty sheets in the active workbook.
% This function loops through all sheets and deletes those sheets that are empty.
% Can be used to clean a newly created xls-file after all results have been saved in it.
function DeleteEmptyExcelSheets(excelObject)
try
	% 	excelObject = actxserver('Excel.Application');
	% 	excelWorkbook = excelObject.workbooks.Open(fileName);
	
	% Run Yair's program http://www.mathworks.com/matlabcentral/fileexchange/17935-uiinspect-display-methods-properties-callbacks-of-an-object
	% to see what methods and properties the Excel object has.
	% 	uiinspect(excelObject);
	
	worksheets = excelObject.sheets;
	sheetIndex = 1;
	sheetIndex2 = 1;
	initialNumberOfSheets = worksheets.Count;
	% Prevent beeps from sounding if we try to delete a non-empty worksheet.
	excelObject.EnableSound = false;
	% Tell it to not ask you for confirmation to delete the sheet(s).
	excelObject.DisplayAlerts = false;
	
	% Loop over all sheets
	while sheetIndex2 <= initialNumberOfSheets
		% Saves the current number of sheets in the workbook.
		preDeleteSheetCount = worksheets.count;
		% Check whether the current worksheet is the last one. As there always
		% need to be at least one worksheet in an xls-file the last sheet must
		% not be deleted.
		if or(sheetIndex>1,initialNumberOfSheets-sheetIndex2>0)
			% worksheets.Item(sheetIndex).UsedRange.Count is the number of used cells.
			% This will be 1 for an empty sheet.  It may also be one for certain other
			% cases but in those cases, it will beep and not actually delete the sheet.
			if worksheets.Item(sheetIndex).UsedRange.Count == 1
				worksheets.Item(sheetIndex).Delete;
			end
		end
		% Check whether the number of sheets has changed. If this is not the
		% case the counter "sheetIndex" is increased by one.
		postDeleteSheetCount = worksheets.count;
		if preDeleteSheetCount == postDeleteSheetCount;
			% If this sheet was not empty, and wasn't deleted, move on to the next sheet.
			sheetIndex = sheetIndex + 1;
		else
			% sheetIndex stays the same.  It's not incremented because the current sheet got deleted,
			% and all the other sheets shift down in their sheet number.  So now sheetIndex will
			% point to the same number which is the next sheet in line for checking.
		end
		sheetIndex2 = sheetIndex2 + 1; % prevent endless loop...
	end
	excelObject.EnableSound = true;
catch ME
	errorMessage = sprintf('Error in function DeleteEmptyExcelSheets.\n\nError Message:\n%s', ME.message);
	fprintf('%s\n', errorMessage);
	WarnUser(errorMessage);
end
return; % from DeleteEmptyExcelSheets
end % of DeleteEmptyExcelSheets
