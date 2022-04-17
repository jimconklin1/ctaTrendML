function PLAnalysisGUI(Close,EquityCurve,Signals,Weights)

% SIMPLE_GUI2 
% Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

% STEP 1 LAYING OUT THE GUI(my comment)------------------------------------

%  Initialize and hide the GUI as it is being constructed.

%my comments                                     Width Height
f = figure('Visible','of','Position',[360, 500, 1000, 700]);

% SELECT ASSET-------------------------------------------------------------
htext  = uicontrol('Style','text','String','Information Ratio','Position',[30,650,100,15]);  
%htext2  = uicontrol('Style','text','String','Information Ratio',...
%           'Position',[30,970,100,15]);         
%hlbox = uicontrol('Style','listbox',...
%                'String',{'SP1', 'ND1' , ...
%                          'VG1', 'GX1', 'Z 1', ...
%                          'NK1', 'XP1', 'HI1', 'HC1', 'TW1', 'KM1', 'QZ1', 'IH1', ...
%                          'TY1', 'CN1', 'G 1', 'RX1', 'JB1', 'XM1', ...
%                          'CL1','HG1','GC1', 'W 1', ...
%                          'EURUSD','GBPUSD','AUDUSD','NZDUSD', ...
%                          'USDCAD', ...
%                          'USDCHF','USDDKK','USDSEK','USDNOK', ...
%                          'USDJPY', ...
%                          'USDSGD','USDHKD','USDKRW','USDTWD','USDINR', ...
%                          'USDZAR','USDBRL','USDMXN'},...
%                'Value',1,'Position',[30,400,100,550],...
%                'Callback',{@listbox_Callback}); 

% CONSTRUCT COMPONENTS-----------------------------------------------------
%hGoldDeathCross = uicontrol('Style','pushbutton','String','Gold/Death Cross',...
%        'Position',[150,920,100,25],...
%        'Callback',{@GoldDeathCross_Callback});
%hmesh = uicontrol('Style','pushbutton','String','Simple MACDD',...
%          'Position',[150,880,100,25],...
%          'Callback',{@meshbutton_Callback});
%hcontour = uicontrol('Style','pushbutton',...
%          'String','MACD+Boll',...
%          'Position',[150,840,100,25],...
%          'Callback',{@contourbutton_Callback});
%hpopup = uicontrol('Style','popupmenu',...
%          'String',{'Peaks','Membrane','Sinc'},...
%          'Position',[150,800,100,25],...
%          'Callback',{@popup_menu_Callback});
% Allign components       
%align([hGoldDeathCross,hmesh,hcontour,hpopup],'Center','None');      
          
       
%CHARTS--------------------------------------------------------------------
%                                      fromleft  frombottom    width  height                                             
hSearchOpt = axes('Units','pixels','Position',[450,     350,   500, 300]);   

% SELECTED EQUITY CURVE----------------------------------------------------
%                                      fromleft  frombottom    width  height                                             
%hEqCurve = axes('Units','pixels','Position',[550,      50,          800, 400]);   
%align([hSearchOpt,hSearchOpt],'Center','None');    

data = MyUitable(rand(3,2));
%hAxes = axes('units','pixels','position',[45 45 200 140]);
%a = MyUitable(hAxes, cell(3,12));

% STEP 2 INITIALIZING THE GUI(my comment)----------------------------------
% make the GUI visible

% Initialize the GUI.
% Change units to normalized so components resize automatically.
%set([f,hSearchOpt,hEqCurve,hGoldDeathCross,hmesh,hcontour,htext,hpopup],'Units','normalized');

% Create a plot in the axes.
%CurrentData = EquityCurve;%peaks_data;
TimeX=(1:1:size(EquityCurve,1))';
%plot(hSearchOpt,EquityCurve);
 [AX,H1,H2]=plotyy(hSearchOpt,TimeX,Close,TimeX,EquityCurve);
    title('Asset & P&L');
    set(get(AX(1),'Ylabel'),'String','Asset','Color','b');
    set(AX(1),'YColor','b');    set(H1,'LineWidth',1,'Color','b'); 
    set(get(AX(2),'Ylabel'),'String','PL','Color','r');  
    set(AX(2),'YColor','r');    set(H2,'LineWidth',2,'Color','r');      
%surf(hSearchOpt,current_data);


% Assign the GUI a name to appear in the window title.
set(f,'Name','PL Analysis')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');

% STEP 3 PROGRAMMING THE GUI(my comment)-----------------------------------

% Programming the Pop-Up Menu
% The pop-up menu enables users to select the data to plot
%  Pop-up menu callback. Read the pop-up menu Value property to
%  determine which item is currently displayed and make it the
%  current data. This callback automatically has access to 
%  current_data because this function is nested at a lower level.

 %  function listbox_Callback(source,eventdata) 
 %     % Path
 %     maindrive='S:\';  dir1='08 Trading\';     
 %     dir2='088 Quantitative Global Macro\';    dir3='0881 CrossAssets\';
 %    dirname=strcat(maindrive,dir1,dir2,dir3);
 %     % Filename
 %     filename='GlobalFX_Value.xls';     
 %     % Data Range
 %     DataRange='A2:F10000';
 %     % Determine the selected data set.
 %     str = get(source, 'String');  val = get(source,'Value');
 %     % Set current data to the selected data set.
 %     switch str{val};
 %     case str{val}  
 %       sheetname=str{val};      
 %       asset=xlsread(strcat(dirname,filename),sheetname,DataRange);
 %       % Upload Open, High, Low, Close
 %       oa=asset(:,2); ha=asset(:,3);
 %       la=asset(:,4); ca=asset(:,5);     
 %       plot(hEqCurve,ca); 
 %     end
 %  end

 %  function popup_menu_Callback(source,eventdata) 
      % Determine the selected data set.
 %     str = get(source, 'String');
 %     val = get(source,'Value');
 %     current_data = EquityCurve;
 %  end 
      

%Programming the Push Buttons
% Push button callbacks. Each callback plots current_data in the
% specified plot type.

%function listbox_Callback(source,eventdata) 
% Display surf plot of the currently selected data.
%     surf(current_data);
%end


%function meshbutton_Callback(source,eventdata) 
% Display mesh plot of the currently selected data.
    % mesh(hSearchOpt,current_data);
%    plot(hSearchOpt,sin(ca)-cos(ca));
%end

%function contourbutton_Callback(source,eventdata) 
% Display contour plot of the currently selected data.
     %contour(hSearchOpt,current_data);
%     plot(hSearchOpt,power(ca,3)-2*power(ca,2)+ca-1);
%end


end