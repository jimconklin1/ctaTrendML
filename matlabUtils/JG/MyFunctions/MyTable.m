function data = MyTable(fig, hObj, columnInfo, rowHeight, cell_data, gFont)
% Initially creates the table
%-------------------------------------------------------------------------
global MINROWS

fig = resizeTable(fig, hObj);
data.figure = fig;
% get axes position in pixel coordinates
set(hObj, 'units', 'pixels');
set(hObj, 'visible', 'on');
pos_ax = get(hObj, 'position');
% set up grid info structure
ds = size(cell_data);
data.maxRows = ds(1);
if data.maxRows < MINROWS
    blanks = cell(1, ds(2));
    for ii = data.maxRows+1:MINROWS
        cell_data = [cell_data; blanks];
    end
    data.maxRows = MINROWS;
end
data.data = cell_data;
data.isChecked = zeros(1,size(cell_data, 1));
data.axes = hObj;
data.userModified = zeros(ds);
data.rowHeight = rowHeight;
data.columnInfo = columnInfo;
data.numCols= length(columnInfo.titles);
data.ltGray = [92 92 92]/255;
data.OffscreenPos = [-1000 -1000 30 20];
data.selectedRow = 0;
data.selectedCol = 0;
data.gFont = gFont;

data.doCheck = false;
if isfield(data.columnInfo, 'withCheck') && ...
    data.columnInfo.withCheck ~= 0
    data.doCheck = true;
end

% use 0...1 scaling on table x and y positions
set(fig, 'CurrentAxes', data.axes);
set(data.axes, 'box', 'on', 'DrawMode', 'fast');
set(data.axes, 'xlimmode', 'manual', 'xlim', [0 1], 'ylim', [0 1], ...
               'xtick', [], 'ytick', [], 'xticklabelmode', 'manual', 'xticklabel', []);
           
if data.doCheck % shrink on left for checkboxes column
    data.checkdx = pos_ax(3) * 20 * (1/pos_ax(3)); % chkbox offset
    pos_ax(1) = pos_ax(1) + data.checkdx;
    pos_ax(3) = pos_ax(3) - data.checkdx;
end
pos_ax(3) = pos_ax(3) - 10; % width of slider
set(data.axes, 'position', pos_ax, 'LineWidth', 2);
% callback for starting editing 
editfcn = sprintf('mltable(%14.13f, %14.13f, ''EditCell'');',fig, hObj);
set(data.axes, 'ButtonDownFcn', editfcn);
% callback for scrolling table
scrfcn = sprintf('mltable(%14.13f, %14.13f, ''ScrollData'');',fig, hObj);
data.slider = uicontrol('style', 'slider', 'units', 'pixels',...
    'position', [pos_ax(1)+pos_ax(3)+2 pos_ax(2) 16 pos_ax(4)],...
    'Callback', scrfcn);

% Add buttons for addrow/delrow
if sum(columnInfo.isEditable) > 0 && (~isfield(columnInfo,'rowsFixed') ||...
        ~columnInfo.rowsFixed)
	btnw = 19; btnh = 15;
	btnx = pos_ax(1) + pos_ax(3) - btnw - 2;
	btny = pos_ax(2) + pos_ax(4) + 2;
	btnfcn = sprintf('mltable(%14.13f, %14.13f, ''AddRow'');',fig, hObj);
	data.btnAdd = uicontrol('style', 'pushbutton', 'units', 'pixels',...
        'position', [btnx, btny, btnw, btnh],...
        'string',' + ','fontsize',12,'Callback', btnfcn,...
        'TooltipString','Click to add a row');
	btnfcn = sprintf('mltable(%14.13f, %14.13f, ''DelRow'');',fig, hObj);
	data.btnDel = uicontrol('style', 'pushbutton', 'units', 'pixels',...
        'position', [btnx + btnw + 2, btny, btnw, btnh],...
        'string',' - ','fontsize',12,'Callback', btnfcn,...
        'TooltipString','Click to remove selected row');
	
	set(data.btnAdd,'Units','normalized');
	set(data.btnDel,'Units','normalized');
else
    data.btnAdd = [];
    data.btnDel = [];
end

set(hObj, 'UserData', data);
% so clicking outside the table will finish edit in progress
endfcn = sprintf('mltable(%14.13f, %14.13f, ''SetCellValue'');', fig, hObj);
set(fig,'buttondownfcn',endfcn);

resizeTable(fig, hObj);

return