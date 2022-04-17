function MovingAverageGUI

% SIMPLE_GUI2 
% Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

% STEP 1 LAYING OUT THE GUI(my comment)------------------------------------

%  Initialize and hide the GUI as it is being constructed.

%my comments                                     Width Height
f = figure('Visible','off','Position',[360, 500, 1500, 1000]);

% SELECT ASSET-------------------------------------------------------------
htext  = uicontrol('Style','text','String','Select Asset',...
           'Position',[30,970,100,15]);  
hlbox = uicontrol('Style','listbox',...
                'String',{'SP1', 'ND1' , ...
                          'VG1', 'GX1', 'Z 1', ...
                          'NK1', 'XP1', 'HI1', 'HC1', 'TW1', 'KM1', 'QZ1', 'IH1', ...
                          'TY1', 'CN1', 'G 1', 'RX1', 'JB1', 'XM1', ...
                          'CL1','HG1','GC1', 'W 1', ...
                          'EURUSD','GBPUSD','AUDUSD','NZDUSD', ...
                          'USDCAD', ...
                          'USDCHF','USDDKK','USDSEK','USDNOK', ...
                          'USDJPY', ...
                          'USDSGD','USDHKD','USDKRW','USDTWD','USDINR', ...
                          'USDZAR','USDBRL','USDMXN'},...
                'Value',1,'Position',[30,400,100,550],...
                'Callback',{@listbox_Callback}); 

% CONSTRUCT COMPONENTS-----------------------------------------------------
hGoldDeathCross = uicontrol('Style','pushbutton','String','Gold/Death Cross',...
        'Position',[150,920,100,25],...
        'Callback',{@GoldDeathCross_Callback});
hmesh = uicontrol('Style','pushbutton','String','Simple MACDD',...
          'Position',[150,880,100,25],...
          'Callback',{@meshbutton_Callback});
hcontour = uicontrol('Style','pushbutton',...
          'String','MACD+Boll',...
          'Position',[150,840,100,25],...
          'Callback',{@contourbutton_Callback});
hpopup = uicontrol('Style','popupmenu',...
          'String',{'Peaks','Membrane','Sinc'},...
          'Position',[150,800,100,25],...
          'Callback',{@popup_menu_Callback});
% Allign components       
align([hGoldDeathCross,hmesh,hcontour,hpopup],'Center','None');      
          
       
% 3D CHARTS----------------------------------------------------------------
%                                      fromleft  frombottom    width  height                                             
hSearchOpt = axes('Units','pixels','Position',[550,      550,   800, 400]);   

% SELECTED EQUITY CURVE----------------------------------------------------
%                                      fromleft  frombottom    width  height                                             
hEqCurve = axes('Units','pixels','Position',[550,      50,          800, 400]);   
align([hSearchOpt,hSearchOpt],'Center','None');    


% STEP 2 INITIALIZING THE GUI(my comment)----------------------------------
% make the GUI visible

% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,hSearchOpt,hEqCurve,hGoldDeathCross,hmesh,hcontour,htext,hpopup],'Units','normalized');

% Generate the data to plot.
peaks_data = peaks(35);
membrane_data = membrane;
[x,y] = meshgrid(-8:.5:8);
r = sqrt(x.^2+y.^2) + eps;
sinc_data = sin(r)./r;

% Create a plot in the axes.
current_data = peaks_data;
surf(hSearchOpt,current_data);

oa=ones(50);ha=ones(50);
la=ones(50);ca=ones(50);

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

   function listbox_Callback(source,eventdata) 
      % Path
      maindrive='S:\';  dir1='08 Trading\';     
      dir2='088 Quantitative Global Macro\';    dir3='0881 CrossAssets\';
      dirname=strcat(maindrive,dir1,dir2,dir3);
      % Filename
      filename='GlobalFX_Value.xls';     
      % Data Range
      DataRange='A2:F10000';
      % Determine the selected data set.
      str = get(source, 'String');  val = get(source,'Value');
      % Set current data to the selected data set.
      switch str{val};
      case str{val}  
        sheetname=str{val};      
        asset=xlsread(strcat(dirname,filename),sheetname,DataRange);
        % Upload Open, High, Low, Close
        oa=asset(:,2); ha=asset(:,3);
        la=asset(:,4); ca=asset(:,5);     
        plot(hEqCurve,ca); 
      end
   end

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

%function listbox_Callback(source,eventdata) 
% Display surf plot of the currently selected data.
%     surf(current_data);
%end

function GoldDeathCross_Callback(source,eventdata) 
% Display surf plot of the currently selected data.
     %surf(hSearchOpt,current_data);
     %plot(hSearchOpt,sin(ca));
     %_____________________________________________________________________
     % GOLD / DEATCH CROSS OPTIMISER
     %---------------------------------------------------------------------
     %
        c=ca;o=oa;h=ha;l=la;
        % Increment for MA ATR
        % Increment for MA Mid Point
        MinX=1; MaxX=30;
        X=(MinX:1:MaxX)';
        % Increment for Std ATR
        % Increment for Nb STD
        MinY=1;     MaxY=3;
        Y=(MinY:1:MaxY)';

        MaxZ=MaxX*MaxY;
        Z=zeros(MaxZ,3);

        XX=repmat(X,1,MaxY); XXRow=zeros(1,1);
        for u=1:MaxX, XXRow=[XXRow,XX(u,:)]; end
        XXRow=XXRow'; XXRow(1,:)=[];Z(:,1)=XXRow;

        %YY=repmat(Y,1,MaxX); YYRow=zeros(1,1);
        %for u=1:MaxX, YYRow=[YYRow;YY(:,u)]; end
        %YYRow=YYRow; YYRow(1,:)=[];
        Z(:,2)=repmat(Y,MaxX,1);

        for CounterZ=1:MaxZ

            % Set Dimension & Prelocation______________________________________________
            % Dimensions---------------------------------------------------------------
            nsteps=length(c);
            % Carry forward Next Day Open to alligne data base-------------------------
            p(1:nsteps-1,1)=o(2:nsteps,1); 
            p(nsteps,1)=p(nsteps-1,1);
            % Pre-locate matrix--------------------------------------------------------
                % Signals..............................................................
                s=zeros(size(c));
                % Profit...............................................................
                profit=zeros(size(c));          sumprofit=zeros(size(c));
                ProfitInOut=zeros(size(c));     SumprofitInOut=zeros(size(c));
                GeoEC=zeros(size(c));
                HoldLong=zeros(size(c));        HoldShort=zeros(size(c)); 
                ExecP=zeros(size(c)); 

            % Increment 
            VarX=Z(CounterZ,1); VarY=Z(CounterZ,2);
            td=BloombergTrender(o,h,l,c,[3,VarX,VarY,3]);    %3,20,5,1

            Model=0;
            method='coc';
            TC=0.0002;
            % Step 5.: Extract Trading Signal__________________________________________
            for i=250:nsteps   
                % Step 5.1. : Compute Min & Max----------------------------------------
                % No extra condition...................................................
                if Model==0
                    % Enter Long-------------------------------------------------------            
                    if s(i-1)~=1 &&    c(i)>td(i)
                        s(i)=+1;   ExecP(i)=p(i)*(1+TC);   HoldLong(i)=0;
                    % Hold Long........................................................
                    elseif s(i-1)==1 && c(i)>td(i)
                        s(i)=+1;   ExecP(i)=ExecP(i-1);    HoldLong(i)=HoldLong(i-1)+1;
                    % Enter Short -----------------------------------------------------   
                    elseif  s(i-1)~=-1 &&  c(i)<td(i)
                        s(i)=-1;    ExecP(i)=p(i)*(1-TC);    HoldShort(i)=0;   
                    % Hold Short.......................................................
                    elseif s(i-1)==-1 &&    c(i)<td(i)
                        s(i)=-1;    ExecP(i)=ExecP(i-1);     HoldShort(i)=HoldShort(i-1)+1;                      
                    end              
                elseif Model==2       
                end
                % Step 5.2..: Profit---------------------------------------------------
                switch method
                    case 'ccc'
                        factor_TC=0;
                        if s(i-1)==s(i-2);
                            factor_TC=0;
                        else
                            factor_TS=1;
                        end
                        profit(i)=s(i-1)*((1-s(i-1)*factor_TC*TC)*c(i) - (1+s(i-1)*factor_TC*TC)*c(i-1))/((1+s(i-1)*factor_TC*TC)*c(i-1));
                    case 'coc'
                        factor_TC=0;
                        if s(i-1)==s(i-2);
                            factor_TC=0;
                        else
                            factor_TS=1;
                        end            
                        profit(i)=s(i-1)*((1-s(i-1)*factor_TC*TC)*c(i) - ...
                            (1+s(i-1)*factor_TC*TC)*o(i))/((1+s(i-1)*factor_TC*TC)*o(i)); 
                    case 'coo'
                        factor_TC=0;
                        if s(i-1)==s(i-2);
                            factor_TC=0;
                        else
                            factor_TS=1;
                        end            
                        profit(i)=s(i-1)*((1-s(i-1)*factor_TC*TC)*p(i) - ...
                            (1+s(i-1)*factor_TC*TC)*o(i))/((1+s(i-1)*factor_TC*TC)*o(i));           
                end    
                % Step 5.3.: Sumprofit-------------------------------------------------
                sumprofit(i)=sumprofit(i-1)+profit(i);
                % Step 2.3.: In - Out Profit & SumProfit-------------------------------
                if s(i)~=s(i-1) && ExecP(i-1)~=0
                    ProfitInOut(i)=s(i-1) *  ((1-s(i-1)*TC)*p(i)-ExecP(i-1)) / ExecP(i-1);
                end
                SumprofitInOut(i)=SumprofitInOut(i-1)+ProfitInOut(i);      
            end
            %
            % Compute the Geometric equity Curve_______________________________________
            for i=1:nsteps  
                if ExecP(i)~=0
                    start_time_ec=i;
                    break
                end
            end
            for i=1:start_time_ec  
                GeoEC(i)=100;
            end
            for i=start_time_ec +1:nsteps  
                if s(i)~=s(i-1) && ExecP(i-1)~=0
                    PriceReturn=s(i-1) *  ((1-s(i-1)*TC)*p(i)-ExecP(i-1)) / ExecP(i-1);
                    GeoEC(i)=GeoEC(i-1)*(1+PriceReturn);
                elseif s(i)==s(i-1) || (s(i-1)==0 && s(i)~=0)
                    GeoEC(i)=GeoEC(i-1);
                end
            end
            % Pure GeoEC
            PGeoEC=zeros(1,1);
            for i=start_time_ec +1:nsteps 
                if GeoEC(i)~=GeoEC(i-1)
                    PGeoEC=[PGeoEC;GeoEC(i)];
                end
            end
            PGeoEC(1)=100;
            LengthGeoEC=length(PGeoEC);
            if LengthGeoEC>=2 
                TotReturn=GeoEC(LengthGeoEC)/GeoEC(1)-1;
                ROCGeoEC=RateofChange(PGeoEC,'rate of change',1);
                IRPGeoEC=TotReturn/std(ROCGeoEC);
            else
                %No Signal
                IRPGeoEC=-20;
            end


            Z(CounterZ,3)=IRPGeoEC;

        end

        ZZ=[Z(:,1),Z(:,2),Z(:,3)];
        %figure(1);  surf(ZZ,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
        %surf(hSearchOpt,ZZ);
        surf(hSearchOpt,ZZ,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
        xlabel('VarX'); ylabel('VarY'); zlabel('IR');
        title('Trading Factor Optimization');   camlight right; view(30,30);
        
        plot(hEqCurve,ca);

        % Build Matrix
        ZMat=zeros(MaxX,MaxY);
        for u=1:MaxX
            ZMat(u,:)=Z((u-1)*MaxY+1:u*MaxY,3);
        end
        %ZMat=[X,ZMat]; 
        %TY=[0,Y'];ZMat=[TY;ZMat];

        % Best Combination
        MaxValue=max(Z(:,3));
        for u=1:MaxZ
            if Z(u,3)==MaxValue
                TargetRow=u;
                break
            end
        end
        BestParameters=Z(TargetRow,:);
     %_____________________________________________________________________
     % RUN MACRO WITH BEST PARAMETERS
     %---------------------------------------------------------------------
     %_____________________________________________________________________      
     
     
end

function meshbutton_Callback(source,eventdata) 
% Display mesh plot of the currently selected data.
    % mesh(hSearchOpt,current_data);
    plot(hSearchOpt,sin(ca)-cos(ca));
end

function contourbutton_Callback(source,eventdata) 
% Display contour plot of the currently selected data.
     %contour(hSearchOpt,current_data);
     plot(hSearchOpt,power(ca,3)-2*power(ca,2)+ca-1);
end


end