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

% Last Modified by GUIDE v2.5 18-Apr-2016 16:27:00

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
    % t = readtable(str,'Delimiter','\t','ReadVariableNames',true);
    % deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
    
    % older version 2013
    fid = fopen(str);
    C = textscan(fid,'%s %t %s','HeaderLines',1); % Read data skipping header
    fclose(fid);                                % Don't forget to close file
    deftSet = containers.Map(C{1,1},C{1,2});
    
    set(handles.cur_path, 'string', deftSet('cur_path'));
    set(handles.job_dir_path, 'string', deftSet('job_dir_path'));
    set(handles.aal_file, 'string', deftSet('aal_file'));
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
scr_fcn_run_all(params);

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
str = spm_select(1,'dir','Select directory which involves PET, MRI images');
set(handles.cur_path, 'string', str);


% --- Executes on button press in selJobDirBtn.
function selJobDirBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selJobDirBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory which involves involve job files');
set(handles.job_dir_path, 'string', str);


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
str = spm_select(1,'dir','Select directory to save above settings');
if exist(str, 'dir')
    handles.savDefSetDir = str;
    guidata(hObject,handles);
    set(handles.selDefSetDirStt, 'string', 'Done');
    set(handles.savDefSetBtn, 'enable', 'on');
end


% --- Executes on button press in savDefSetBtn.
function savDefSetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savDefSetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = 'VAR_NAME\tVAR_VALUE\n';
s_strs = {get(handles.cur_path, 'string');...
    get(handles.job_dir_path, 'string');...
    get(handles.aal_file, 'string')};

s_strs = strrep(s_strs, '\', '\\');

str = [ str 'cur_path' '\t' s_strs{1,1} '\n'];
str = [ str  'job_dir_path' '\t' s_strs{2,1} '\n'];
str = [ str  'aal_file' '\t' s_strs{3,1}];

fileName = fullfile(handles.savDefSetDir, 'DEFAULT_SETTINGS_1234.txt');
fileID = fopen(fileName,'w');
fprintf(fileID,str);
fclose(fileID);
set(hObject,'enable','off');
