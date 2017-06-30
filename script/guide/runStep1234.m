function varargout = runStep1234(varargin)
% RUNSTEP1234 MATLAB code for runStep1234.fig
%      RUNSTEP1234, by itself, creates a new RUNSTEP1234 or raises the existing
%      singleton*.
%
%      H = RUNSTEP1234 returns the handle to a new RUNSTEP1234 or the handle to
%      the existing singleton*.
%
%      RUNSTEP1234('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNSTEP1234.M with the given input arguments.
%
%      RUNSTEP1234('Property','Value',...) creates a new RUNSTEP1234 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runStep1234_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runStep1234_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runStep1234

% Last Modified by GUIDE v2.5 28-Jun-2017 01:05:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runStep1234_OpeningFcn, ...
                   'gui_OutputFcn',  @runStep1234_OutputFcn, ...
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


% --- Executes just before runStep1234 is made visible.
function runStep1234_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runStep1234 (see VARARGIN)

% Choose default command line output for runStep1234
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runStep1234 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runStep1234_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
str = scr_get_spm8_dir();
if exist(fullfile(str, 'toolbox/pet_mri_tool/necessaryFiles'), 'dir') == 7
    set(handles.job_dir_path, 'string', fullfile(str, 'toolbox/pet_mri_tool/necessaryFiles'));
    set(handles.aal_file, 'string', fullfile(str, 'toolbox/pet_mri_tool/necessaryFiles/ROI_MNI_V4.nii'));
    
    % set(handles.warningTag, 'string', 'OK!');
    set(handles.runBtn, 'enable', 'on');
else
    set(handles.warningTag, 'string', 'check whether spm8 folder location in file <global_setting.txt> correct or not!');
    set(handles.runBtn, 'enable', 'off');
end
varargout{1} = handles.output;


% --- Executes on button press in loadDefSetBtn.
function loadDefSetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadDefSetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[str, filePath] = uigetfile('.txt' ,'Select default setting file (DEFAULT_SETTINGS.txt).');
str = fullfile(filePath, str);
if exist(str, 'file')
    % from version 2013
    t = readtable(str,'Delimiter','\t','ReadVariableNames',true);
    deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
    
    % older version 2013
%     fid = fopen(str);
%     C = textscan(fid,'%s %t %s','HeaderLines',1); % Read data skipping header
%     fclose(fid);                                % Don't forget to close file
%     deftSet = containers.Map(C{1,1},C{1,2});
    
    try
        set(handles.cur_path, 'string', deftSet('cur_path'));
        set(handles.job_dir_path, 'string', deftSet('job_dir_path'));
        set(handles.aal_file, 'string', deftSet('aal_file'));
        set(handles.scaninfo_file, 'string', deftSet('scaninfo_file'));
    catch
    end
end


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check completely chosen mandatory fields
if ~checkChosenManFields(handles)
    return;
end
params = struct();
params.cur_path = get(handles.cur_path, 'string');
params.job_dir_path = get(handles.job_dir_path, 'string');
params.aal_file = get(handles.aal_file, 'string');
params.binThresh = str2double(get(handles.binThrMatEdit, 'String'));
params.steps = [1 1 1 1 0];
scaninfo = struct();
scaninfo.filename = get(handles.scaninfo_file, 'string');
sheet_int = str2num(get(handles.sheetEditTxt, 'string'));

% check if sheet index is integer
if floor(sheet_int)== sheet_int
    scaninfo.sheet = sheet_int;
else
    warndlg('Sheet index should be an integer number. Please re-type.');
    return;
end

% check if existing file temp.mat in necessaryFiles
try 
    load(fullfile(scr_get_spm8_dir(),'toolbox\pet_mri_tool\necessaryFiles\temp.mat'));
    scaninfo.setCol = setColData;
    scaninfo.cols = sVals2i;
catch
    warndlg('Please Set Column index by "Set Column" button to read patient info Excel file !');
    return;
end
% scaninfo.setCol = get(hObject, 'UserData');

params.scaninfo = scaninfo;
params.approach = get(handles.popupmenu1, 'value'); % default is 2
% scr_fcn_run_all_with_excel(params); % run along to 4 steps
scr_fcn_run_all_with_excel_each_one(params); % run along to subjetcs
% scr_fcn_run_all_sub_notemp(params); % TODO for no sub no temp

function isOk = checkChosenManFields(handles)
isOk = false;
if ~exist(get(handles.cur_path, 'String'), 'dir')
    warndlg('Please choose DIRECTORY included PET, MRI images at [1] !');
    return;
end

if ~exist(get(handles.job_dir_path, 'String'), 'dir')
    warndlg('Please choose DIRECTORY included job files at [2] !');
    return;
end

if ~exist(get(handles.aal_file, 'String'), 'file')
     warndlg('Please choose Template FILE "ROI_MNI_V4.nii" at [3] !');
     return;
end

if isnan(str2double(get(handles.binThrMatEdit, 'String')))
    warndlg('Please set binarized White Matter threshold as a NUMBER !');
    return;
end
isOk = true;

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);



function binThrMatEdit_Callback(hObject, eventdata, handles)
% hObject    handle to binThrMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binThrMatEdit as text
%        str2double(get(hObject,'String')) returns contents of binThrMatEdit as a double


% --- Executes during object creation, after setting all properties.
function binThrMatEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binThrMatEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selImgDirBtn.
function selImgDirBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selImgDirBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = uigetdir('','Select directory which involves PET, MRI images');
set(handles.cur_path, 'string', str);


% --- Executes on button press in selJobDirBtn.
function selJobDirBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selJobDirBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.xlsx;*.xls;*.csv', 'Excel format Files (*.xlsx, *.xls, *.csv)');
str = fullfile(pathname, filename);
% check str is correct?
if exist(str, 'file') == 2
    set(handles.scaninfo_file, 'string', str);
    set(handles.warningTag, 'string', 'OK!');
    set(handles.runBtn, 'enable', 'on');
else
    set(handles.warningTag, 'string', 'SELECTED FILE IS NOT EXACT, PLEASE CHOOSE AGAIN!');
    set(handles.runBtn, 'enable', 'off');
end



% --- Executes on button press in selAALBtn.
function selAALBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selAALBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('.nii' ,'Select AAL file (ROI_MNI_V4.nii).');
str = fullfile(path, file);
set(handles.aal_file, 'string', str);


% --- Executes on button press in selDefSetDirBtn.
function selDefSetDirBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selDefSetDirBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%str = spm_select(1,'dir','Select directory to save above settings');
str_dir = uigetdir('', 'Select directory to save above settings');

if exist(str_dir, 'dir')
    str = 'VAR_NAME\tVAR_VALUE\n';
    s_strs = {get(handles.cur_path, 'string');...
        get(handles.job_dir_path, 'string');...
        get(handles.aal_file, 'string');...
        get(handles.scaninfo_file, 'string')};

    s_strs = strrep(s_strs, '\', '\\');

    str = [ str 'cur_path' '\t' s_strs{1,1} '\n'];
    str = [ str  'job_dir_path' '\t' s_strs{2,1} '\n'];
    str = [ str  'aal_file' '\t' s_strs{3,1} '\n'];
    str = [ str  'scaninfo_file' '\t' s_strs{4,1}  '\n'];

    fileName = fullfile(str_dir, 'DEFAULT_SETTINGS_1234.txt');
    fileID = fopen(fileName,'w');
    fprintf(fileID,str);
    fclose(fileID);
    set(hObject,'enable','off');
    set(handles.selDefSetDirStt, 'string', 'Done');
end


% --- Executes on button press in savDefSetBtn.
function savDefSetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savDefSetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function sheetEditTxt_Callback(hObject, eventdata, handles)
% hObject    handle to sheetEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sheetEditTxt as text
%        str2double(get(hObject,'String')) returns contents of sheetEditTxt as a double


% --- Executes during object creation, after setting all properties.
function sheetEditTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sheetEditTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in setColumnBtn.
function setColumnBtn_Callback(hObject, eventdata, handles)
% hObject    handle to setColumnBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(setColumn);
% load('temp.mat');
% hObject.UserData = setColData;

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
aa = 1;
save(fullfile(scr_get_spm8_dir(),'toolbox\pet_mri_tool\necessaryFiles\temp.mat'),'aa');


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
selectedItem = {get(hObject,'Value')};
selectedIdx = selectedItem{1,1};
explainStr = scr_get_setting('explain_method_new_old');
set(handles.explainMethodTxt, 'string', explainStr{selectedIdx,1});

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
