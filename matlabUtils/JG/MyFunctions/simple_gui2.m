function simple_gui2

% SIMPLE_GUI2 
% Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

% STEP 1 LAYING OUT THE GUI(my comment)------------------------------------

%  Initialize and hide the GUI as it is being constructed.

%my comments                                Width Height
f = figure('Visible','off','Position',[360,500,450,285]);

% Construct the components.
% my comment: Function originelle
%hsurf    = uicontrol('Style','pushbutton',...
%             'String','Surf','Position',[315,220,70,25]);
% Associer ici le callback a un evenement particulier
hsurf = uicontrol('Style','pushbutton','String','Surf',...
        'Position',[315,220,70,25],...
        'Callback',{@surfbutton_Callback});

% my comment: Function originelle    
%hmesh    = uicontrol('Style','pushbutton',...
%             'String','Mesh','Position',[315,180,70,25]);
% Associer ici le callback a un evenement particulier
hmesh = uicontrol('Style','pushbutton','String','Mesh',...
          'Position',[315,180,70,25],...
          'Callback',{@meshbutton_Callback});
         
% my comment: Function originelle         
%hcontour = uicontrol('Style','pushbutton',...
%             'String','Countour','Position',[315,135,70,25]);
% Associer ici le callback a un evenement particulier
   hcontour = uicontrol('Style','pushbutton',...
          'String','Countour',...
          'Position',[315,135,70,25],...
          'Callback',{@contourbutton_Callback});

% my comment: Function originelle          
%hpopup = uicontrol('Style','popupmenu',...
%           'String',{'Peaks','Membrane','Sinc'},...
%           'Position',[300,50,100,25]);
   hpopup = uicontrol('Style','popupmenu',...
          'String',{'Peaks','Membrane','Sinc'},...
          'Position',[300,50,100,25],...
          'Callback',{@popup_menu_Callback});
       
htext  = uicontrol('Style','text','String','Select Data',...
           'Position',[325,90,60,15]);         
       
ha = axes('Units','pixels','Position',[50,60,200,185]);   

align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');

%set(f,'Visible','on')
% my comment: ce code va etre remplace directement apres STEP 2 par un
% pavet commencant pas % Initialize the GUI

% STEP 2 INITIALIZING THE GUI(my comment)----------------------------------
% make the GUI visible

% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,hsurf,hmesh,hcontour,htext,hpopup],'Units','normalized');

% Generate the data to plot.
peaks_data = peaks(35);
membrane_data = membrane;
[x,y] = meshgrid(-8:.5:8);
r = sqrt(x.^2+y.^2) + eps;
sinc_data = sin(r)./r;

% Create a plot in the axes.
current_data = peaks_data;
surf(current_data);

% Assign the GUI a name to appear in the window title.
set(f,'Name','Simple GUI')
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
   function popup_menu_Callback(source,eventdata) 
      % Determine the selected data set.
      str = get(source, 'String');
      val = get(source,'Value');
      % Set current data to the selected data set.
      switch str{val};
      case 'Peaks' % User selects Peaks.
         current_data = peaks_data;
      case 'Membrane' % User selects Membrane.
         current_data = membrane_data;
      case 'Sinc' % User selects Sinc.
         current_data = sinc_data;
      end
   end 

%Programming the Push Buttons
% Push button callbacks. Each callback plots current_data in the
% specified plot type.

function surfbutton_Callback(source,eventdata) 
% Display surf plot of the currently selected data.
     surf(current_data);
end

function meshbutton_Callback(source,eventdata) 
% Display mesh plot of the currently selected data.
     mesh(current_data);
end

function contourbutton_Callback(source,eventdata) 
% Display contour plot of the currently selected data.
     contour(current_data);
end


end