function varargout = RiskAssetAllocationGUI(varargin)
% RISKASSETALLOCATIONGUI MATLAB code for RiskAssetAllocationGUI.fig
%      RISKASSETALLOCATIONGUI, by itself, creates a new RISKASSETALLOCATIONGUI or raises the existing
%      singleton*.
%
%      H = RISKASSETALLOCATIONGUI returns the handle to a new RISKASSETALLOCATIONGUI or the handle to
%      the existing singleton*.
%
%      RISKASSETALLOCATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RISKASSETALLOCATIONGUI.M with the given input arguments.
%
%      RISKASSETALLOCATIONGUI('Property','Value',...) creates a new RISKASSETALLOCATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RiskAssetAllocationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RiskAssetAllocationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RiskAssetAllocationGUI

% Last Modified by GUIDE v2.5 07-May-2020 11:34:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RiskAssetAllocationGUI_OpeningFcn, ...
    'gui_OutputFcn',  @RiskAssetAllocationGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RiskAssetAllocationGUI is made visible.
function RiskAssetAllocationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RiskAssetAllocationGUI (see VARARGIN)

% Choose default command line output for RiskAssetAllocationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RiskAssetAllocationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RiskAssetAllocationGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RunBtn.
function RunBtn_Callback(hObject, eventdata, handles)
% hObject    handle to RunBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filePath = get(handles.FileLocation,'String');
periods = str2double(get(handles.Periods,'String'));
assetViews = get(handles.AssetViews,'String');
assetView = assetViews{get(handles.AssetViews,'Value')};
utilFunctions = get(handles.UtilityFunctions,'String');
utilityFunction = utilFunctions{get(handles.UtilityFunctions,'Value')};
utilityParam = str2double(get(handles.UtilityParam,'String'));
shrinkageRP= str2double(get(handles.RPShrinkage,'String'));
options = get(handles.LongOnly,'String');
longOnly = strcmp(options{get(handles.LongOnly,'Value')},'True');
liquidationLimit = str2double(get(handles.LiquidationLimit,'String'));
RBCLimit = str2double(get(handles.RBCLimit,'String'));
ICLimit = str2double(get(handles.ICLimit,'String'));
varianceTarget = str2double(get(handles.VarianceTarget,'String'));
illiquidLimit = str2double(get(handles.IlliquidLimit,'String'));
riskTypes = get(handles.RiskTypes,'String');
riskType = riskTypes{get(handles.RiskTypes,'Value')};
clients = get(handles.Clients, 'String');
client = clients{get(handles.Clients,'Value')};

RiskAssetAllocationJC(assetView,filePath,periods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client);


% --- Executes on selection change in AssetViews.
function AssetViews_Callback(hObject, eventdata, handles)
% hObject    handle to AssetViews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AssetViews contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AssetViews


% --- Executes during object creation, after setting all properties.
function AssetViews_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AssetViews (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CancelBtn.
function CancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to CancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq();


% --- Executes on selection change in LongOnly.
function LongOnly_Callback(hObject, eventdata, handles)
% hObject    handle to LongOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LongOnly contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LongOnly


% --- Executes during object creation, after setting all properties.
function LongOnly_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LongOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LiquidationLimit_Callback(hObject, eventdata, handles)
% hObject    handle to LiquidationLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LiquidationLimit as text
%        str2double(get(hObject,'String')) returns contents of LiquidationLimit as a double


% --- Executes during object creation, after setting all properties.
function LiquidationLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LiquidationLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RiskConstraintTypes.
function RiskConstraintTypes_Callback(hObject, eventdata, handles)
% hObject    handle to RiskConstraintTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RiskConstraintTypes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RiskConstraintTypes


% --- Executes during object creation, after setting all properties.
function RiskConstraintTypes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RiskConstraintTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RiskLimit_Callback(hObject, eventdata, handles)
% hObject    handle to RiskLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RiskLimit as text
%        str2double(get(hObject,'String')) returns contents of RiskLimit as a double


% --- Executes during object creation, after setting all properties.
function RiskLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RiskLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in UtilityFunctions.
function UtilityFunctions_Callback(hObject, eventdata, handles)
% hObject    handle to UtilityFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns UtilityFunctions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UtilityFunctions


% --- Executes during object creation, after setting all properties.
function UtilityFunctions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UtilityFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UtilityParam_Callback(hObject, eventdata, handles)
% hObject    handle to UtilityParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UtilityParam as text
%        str2double(get(hObject,'String')) returns contents of UtilityParam as a double


% --- Executes during object creation, after setting all properties.
function UtilityParam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UtilityParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RPShrinkage_Callback(hObject, eventdata, handles)
% hObject    handle to RPShrinkage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RPShrinkage as text
%        str2double(get(hObject,'String')) returns contents of RPShrinkage as a double


% --- Executes during object creation, after setting all properties.
function RPShrinkage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RPShrinkage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileLocation_Callback(hObject, eventdata, handles)
% hObject    handle to FileLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileLocation as text
%        str2double(get(hObject,'String')) returns contents of FileLocation as a double


% --- Executes during object creation, after setting all properties.
function FileLocation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileLocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browserBtn.
function browserBtn_Callback(hObject, eventdata, handles)
% hObject    handle to browserBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filePath = get(handles.FileLocation,'String');
filePath = uigetdir(filePath);
if filePath ~= 0
    set(handles.FileLocation,'String',filePath);
end

function Periods_Callback(hObject, eventdata, handles)
% hObject    handle to Periods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Periods as text
%        str2double(get(hObject,'String')) returns contents of Periods as a double


% --- Executes during object creation, after setting all properties.
function Periods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Periods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Scenarios.
function Scenarios_Callback(hObject, eventdata, handles)
% hObject    handle to Scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Scenarios contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Scenarios

% {CUSTOM,MV.ER.1,PUEC.ER.1,PUEC.ER.2,PUEC.ER.3,PUEC.ER.4,PUEC.ER.5,PUEC.ER.6,PUEC.ER.7,PUEC.ER.8,PUEC.ER.9,PUEC.LNC.1,PUEC.LNC.2}
scenarios = cellstr(get(hObject,'String'));
selectedIndex = get(hObject,'Value');
scenario = scenarios{selectedIndex};
switch scenario
    case "MV.ER.1"
        set(handles.AssetViews,'Value',4);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',1);
        set(handles.RBCLimit,'String','');
        set(handles.ICLimit,'String','');
        set(handles.LiquidationLimit,'String','');
        set(handles.IlliquidLimit,'String','');
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.1"
        set(handles.AssetViews,'Value',4);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.2"
        set(handles.AssetViews,'Value',1);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.3"
        set(handles.AssetViews,'Value',2);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.4"
        set(handles.AssetViews,'Value',3);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.5"
        set(handles.AssetViews,'Value',5);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.6"
        set(handles.AssetViews,'Value',6);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.7"
        set(handles.AssetViews,'Value',7);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.8"
        set(handles.AssetViews,'Value',1);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.ER.9"
        set(handles.AssetViews,'Value',1);
        set(handles.Periods,'String',num2str(1));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.LNC.1"
        set(handles.AssetViews,'Value',1);
        set(handles.Periods,'String',num2str(3));
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    case "PUEC.LNC.2"
        set(handles.AssetViews,'Value',1);
        set(handles.Periods,'Value',3);
        set(handles.UtilityFunctions,'Value',3);
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
        set(handles.IlliquidLimit,'String',num2str(0.6));
        set(handles.VarianceTarget,'String',num2str(0.000408));
    otherwise
end

clients = get(handles.Clients, 'String');
client = clients{get(handles.Clients,'Value')};
switch client
    case "L&R"
        set(handles.RBCLimit,'String',num2str(0.3));
    case "GI"
        set(handles.RBCLimit,'String',num2str(0.15));
    otherwise
end

% --- Executes during object creation, after setting all properties.
function Scenarios_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scenarios (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RBCLimit_Callback(hObject, eventdata, handles)
% hObject    handle to RBCLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RBCLimit as text
%        str2double(get(hObject,'String')) returns contents of RBCLimit as a double


% --- Executes during object creation, after setting all properties.
function RBCLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RBCLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ICLimit_Callback(hObject, eventdata, handles)
% hObject    handle to ICLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ICLimit as text
%        str2double(get(hObject,'String')) returns contents of ICLimit as a double


% --- Executes during object creation, after setting all properties.
function ICLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ICLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IlliquidLimit_Callback(hObject, eventdata, handles)
% hObject    handle to IlliquidLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IlliquidLimit as text
%        str2double(get(hObject,'String')) returns contents of IlliquidLimit as a double


% --- Executes during object creation, after setting all properties.
function IlliquidLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IlliquidLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VarianceTarget_Callback(hObject, eventdata, handles)
% hObject    handle to VarianceTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VarianceTarget as text
%        str2double(get(hObject,'String')) returns contents of VarianceTarget as a double


% --- Executes during object creation, after setting all properties.
function VarianceTarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VarianceTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RiskTypes.
function RiskTypes_Callback(hObject, eventdata, handles)
% hObject    handle to RiskTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RiskTypes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RiskTypes


% --- Executes during object creation, after setting all properties.
function RiskTypes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RiskTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Clients.
function Clients_Callback(hObject, eventdata, handles)
% hObject    handle to Clients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Clients contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Clients

clients = get(handles.Clients, 'String');
client = clients{get(handles.Clients,'Value')};
switch client
    case "L&R"
        set(handles.RBCLimit,'String',num2str(0.3));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
    case "GI"
        set(handles.RBCLimit,'String',num2str(0.15));
        set(handles.ICLimit,'String',num2str(0.3));
        set(handles.LiquidationLimit,'String',num2str(2.5));
    otherwise
end

% --- Executes during object creation, after setting all properties.
function Clients_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Clients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
