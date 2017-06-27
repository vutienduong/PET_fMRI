function varargout = setColumn(varargin)
% SETCOLUMN MATLAB code for setColumn.fig
%      SETCOLUMN, by itself, creates a new SETCOLUMN or raises the existing
%      singleton*.
%
%      H = SETCOLUMN returns the handle to a new SETCOLUMN or the handle to
%      the existing singleton*.
%
%      SETCOLUMN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETCOLUMN.M with the given input arguments.
%
%      SETCOLUMN('Property','Value',...) creates a new SETCOLUMN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setColumn_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setColumn_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setColumn

% Last Modified by GUIDE v2.5 27-Jun-2017 17:38:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setColumn_OpeningFcn, ...
                   'gui_OutputFcn',  @setColumn_OutputFcn, ...
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


% --- Executes just before setColumn is made visible.
function setColumn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setColumn (see VARARGIN)

% Choose default command line output for setColumn
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setColumn wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setColumn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function nameEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to nameEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nameEditTxt as text
%        str2double(get(hObject,'String')) returns contents of nameEditTxt as a double


% --- Executes during object creation, after setting all properties.
function nameEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nameEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mriEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to mriEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mriEditTxt as text
%        str2double(get(hObject,'String')) returns contents of mriEditTxt as a double


% --- Executes during object creation, after setting all properties.
function mriEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mriEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function petEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to petEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of petEditTxt as text
%        str2double(get(hObject,'String')) returns contents of petEditTxt as a double


% --- Executes during object creation, after setting all properties.
function petEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to petEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dosageEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to dosageEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dosageEditTxt as text
%        str2double(get(hObject,'String')) returns contents of dosageEditTxt as a double


% --- Executes during object creation, after setting all properties.
function dosageEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dosageEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function weightEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to weightEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weightEditTxt as text
%        str2double(get(hObject,'String')) returns contents of weightEditTxt as a double


% --- Executes during object creation, after setting all properties.
function weightEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weightEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to timeEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeEditTxt as text
%        str2double(get(hObject,'String')) returns contents of timeEditTxt as a double


% --- Executes during object creation, after setting all properties.
function timeEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sKeys = {'name', 'pet', 'mri', 'weight', 'dosage', 'time', 'header'};
sVals = {get(handles.nameEditTxt, 'String'),...
    get(handles.petEditTxt, 'String'),...
    get(handles.mriEditTxt, 'String'),...
    get(handles.weightEditTxt, 'String'),...
    get(handles.dosageEditTxt, 'String'),...
    get(handles.timeEditTxt, 'String')};

sVals2 = cell(1);
try
    for i=1:length(sVals)
        sVals2{1,i} = uint8(sVals{1,i}) - 64;
    end
    sVals2i = sVals2;
    sVals2{1, length(sVals2) + 1} = get(handles.headerIncludeChBox, 'Value');
catch
    warndlg('Note that column character is A-Z. Please correct!');
    return;
end
setColData = containers.Map(sKeys, sVals2);
save_fold = fullfile(scr_get_spm8_dir(),'toolbox\pet_mri_tool\necessaryFiles\temp.mat');
save(save_fold,'setColData', 'sVals2i');
close(handles.figure1);

% --- Executes on button press in headerIncludeChBox.
function headerIncludeChBox_Callback(hObject, eventdata, handles)
% hObject    handle to headerIncludeChBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of headerIncludeChBox


% --- Executes on button press in defaultBtn.
function defaultBtn_Callback(hObject, eventdata, handles)
% hObject    handle to defaultBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.nameEditTxt, 'String', 'K');
set(handles.mriEditTxt, 'String', 'J');
set(handles.petEditTxt, 'String', 'I');
set(handles.weightEditTxt, 'String', 'L');
set(handles.dosageEditTxt, 'String', 'M');
set(handles.timeEditTxt, 'String', 'N');
