%__________________________________________________________________________
%
% This function insert a mtable in a nice figure
%
%__________________________________________________________________________
%

function f = fromTable2Figure(FlowToday, destPath)


% -- generate figure --
nbfx =size(FlowToday,1);
f = figure(1);
set(f,'Position',[500 500 500 250]);

% day of the week
d = datetime('today'); formatDate = 'yyyy-mm-dd'; 
todayDate = datestr(d, formatDate);
colFlowIdx =  weekday(d); % extract the column needed

dataX = FlowToday(:,colFlowIdx);
tradeOrder = cell(nbfx,1);
FxNames =     {'AUDUSD', 'EURUSD', 'GBPUSD', 'NZDUSD', 'USDCAD', 'USDCHF', 'USDJPY', 'USDNOK',  'USDSEK', 'USDSGD'};

% trade order
for i=1:nbfx
    if dataX(i)<0
        charCross = FxNames{i};
        tradeOrder{i}= strcat('   Sell: ',charCross(1:3), ' - Buy: ',charCross(4:6));
        %if dirIndirQuote(i) == 1
        %    tradeOrder{i}= strcat('Sell ',charCross(1:3), '  - Buy ',charCross(4:6));
        %elseif dirIndirQuote(i) == -1
        %    tradeOrder{i}= strcat('sell ',charCross(1:3));            
        %end
    elseif  dataX(i)>0
        charCross = FxNames{i};
        tradeOrder{i}= strcat('   Buy: ',charCross(1:3), ' - Sell: ',charCross(4:6));
    else
        tradeOrder{i}='   no trade';
    end
end
data = [ FxNames', num2cell(dataX), tradeOrder ];
columnname =   {'Pair', 'Trade size', 'Trade Order'};
columnformat = {'char', 'numeric', 'char'}; 
% % Find the size of data
% dataSize = size(data);
% % Create an array to store the max length of data for each column
% maxLen = zeros(1,dataSize(2));
% % Find out the max length of data for each column
% % Iterate over each column
% for i=1:dataSize(2)
%       % Iterate over each row
%       for j=1:dataSize(1)
%           len = length(data{j,i});
%           % Store in maxLen only if its the data is of max length
%           if(len > maxLen(1,i))
%               maxLen(1,i) = len;
%           end
%       end
% end
maxLen  = [10,10,21];

% Some calibration needed as ColumnWidth is in pixels
cellMaxLen = num2cell(maxLen*10);
hTable = uitable('Units','normalized','Position',...
            [0.05 0.05 0.75 0.9], 'Data', data,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);   %          'ColumnWidth',{150}, ...
% Create UITABLE with required arguments
%hTable=uitable('parent',gcf,'units','pixels','position',[20 20 400 300]);
%set(hTable, 'Data', data);
% Set ColumnWidth of UITABLE
set(hTable, 'ColumnWidth', cellMaxLen);
%set(f,'visible','off');

print(f,'-djpeg','tradeOrders.jpeg') 
%saveas(f, fullfile(destPath, strcat('traderOrders_',todayDate)), 'png');%png  %jpeg      

        
        