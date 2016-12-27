function varargout = runStep5(varargin)
% RUNSTEP5 MATLAB code for runStep5.fig
%      RUNSTEP5, by itself, creates a new RUNSTEP5 or raises the existing
%      singleton*.
%
%      H = RUNSTEP5 returns the handle to a new RUNSTEP5 or the handle to
%      the existing singleton*.
%
%      RUNSTEP5('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNSTEP5.M with the given input arguments.
%
%      RUNSTEP5('Property','Value',...) creates a new RUNSTEP5 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runStep5_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runStep5_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runStep5

% Last Modified by GUIDE v2.5 15-Apr-2016 21:40:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runStep5_OpeningFcn, ...
                   'gui_OutputFcn',  @runStep5_OutputFcn, ...
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



% --- Executes just before runStep5 is made visible.
function runStep5_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runStep5 (see VARARGIN)

% Choose default command line output for runStep5
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runStep5 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(findall(handles.roiPanel, '-property', 'enable'), 'enable', 'off');


% --- Outputs from this function are returned to the command line.
function varargout = runStep5_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cur_pathBtn.
function cur_pathBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cur_pathBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory which involves PET image');
set(handles.cur_path, 'string', str);



% --- Executes on button press in job_dir_pathBtn.
function job_dir_pathBtn_Callback(hObject, eventdata, handles)
% hObject    handle to job_dir_pathBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory which involves involve job files');
set(handles.job_dir_path, 'string', str);

% --- Executes on button press in file_infoBtn.
function file_infoBtn_Callback(hObject, eventdata, handles)
% hObject    handle to file_infoBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathstr] = uigetfile('.txt' ,'Select info file included Weight, Dosage, Time, Half life INFO.');
str = fullfile(pathstr, file);
set(handles.file_info, 'string', str);


function cur_path_Callback(hObject, eventdata, handles)
% hObject    handle to cur_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cur_path as text
%        str2double(get(hObject,'String')) returns contents of cur_path as a double


% --- Executes during object creation, after setting all properties.
function cur_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cur_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function job_dir_path_Callback(hObject, eventdata, handles)
% hObject    handle to job_dir_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of job_dir_path as text
%        str2double(get(hObject,'String')) returns contents of job_dir_path as a double


% --- Executes during object creation, after setting all properties.
function job_dir_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to job_dir_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function file_info_Callback(hObject, eventdata, handles)
% hObject    handle to file_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_info as text
%        str2double(get(hObject,'String')) returns contents of file_info as a double


% --- Executes during object creation, after setting all properties.
function file_info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in aal_tpl_pathBtn.
function aal_tpl_pathBtn_Callback(hObject, eventdata, handles)
% hObject    handle to aal_tpl_pathBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('.txt' ,'Select AAL template file (ROI_MNI_V4.txt).');
str = fullfile(path, file);
set(handles.aal_tpl_path, 'string', str);



function aal_tpl_path_Callback(hObject, eventdata, handles)
% hObject    handle to aal_tpl_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aal_tpl_path as text
%        str2double(get(hObject,'String')) returns contents of aal_tpl_path as a double


% --- Executes during object creation, after setting all properties.
function aal_tpl_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aal_tpl_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doneBtn.
function doneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to doneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check completely Left side mandatory fields
if ~checkManFieldsInLeft(handles)
    return;
end

set(findall(handles.roiPanel, '-property', 'enable'), 'enable', 'on');
set(findall(handles.filePanel, '-property', 'enable'), 'enable', 'off');
hiddenAllChildren(handles.roiPanel, 'on');
hiddenAllChildren(handles.filePanel, 'off');
hiddenAllChildren(handles.suvPanel, 'off');
hiddenAllChildren(handles.suvrPanel, 'off');
set(handles.defRoiBtn, 'enable', 'off');




% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in selectRoiCalSuvBtn.
function selectRoiCalSuvBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selectRoiCalSuvBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roifile = get(handles.aal_tpl_path,'string');
t = readtable(roifile,'Delimiter','\t','ReadVariableNames',false);

% older than version 2013
fid = fopen(roifile);
C = textscan(fid,'%s %t %s','HeaderLines',0); % Read data skipping header
fclose(fid);                                % Don't forget to close file
% TODO: code more

t.Properties.VariableNames = {'Abbr' 'roi_name' 'ID'};
roi_name = t.roi_name;
if hObject == handles.defRoiBtn
    init_vals = [3:16, 19:28, 31:36, 43:56, 59:68, 79:82, 85, 86, 89, 90 ];
elseif isfield(handles, 'roiListGui') % open from 2nd time
    init_vals = handles.roiListGui;
else
    init_vals = [3:16, 19:28, 31:36, 43:56, 59:68, 79:82, 85, 86, 89, 90 ];
    set(handles.defRoiBtn, 'enable', 'on');
end

[s,v] = listdlg('PromptString','Select a ROI to save:',...
                'SelectionMode','multiple',...
                'ListString',roi_name,...
                'Name', 'Select ROIs',...
                'ListSize',[200 300],...
                'InitialValue', init_vals);
if v % choose OK
    roi_ids = t.ID(s);
    
    if length(roi_ids) == 1 %case choose 1 ROI
        roi_ids = [roi_ids];
        roi_names = cell(1);
        roi_names{1,1} = t.roi_name(s);
    else
        roi_names = t.roi_name(s);
    end

    roi_map = containers.Map(roi_ids,roi_names);
    handles.roiList = roi_map;
    handles.roiListGui = s;
    guidata(hObject,handles);
    set(handles.selRoiStt,'String', sprintf('Done [%d]', length(s)));
end


% --- Executes on button press in SUVThCheckbox.
function SUVThCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to SUVThCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggleHiddenBasedCheckbox(handles.SUVThCheckbox, handles.suvPanel);
% Hint: get(hObject,'Value') returns toggle state of SUVThCheckbox


% --- Executes on button press in SUVRThCheckbox.
function SUVRThCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to SUVRThCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggleHiddenBasedCheckbox(handles.SUVRThCheckbox, handles.suvrPanel);
% Hint: get(hObject,'Value') returns toggle state of SUVRThCheckbox



function suvrMapThrholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to suvrMapThrholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of suvrMapThrholdEdit as text
%        str2double(get(hObject,'String')) returns contents of suvrMapThrholdEdit as a double


% --- Executes during object creation, after setting all properties.
function suvrMapThrholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to suvrMapThrholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function suvMapThrholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to suvMapThrholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of suvMapThrholdEdit as text
%        str2double(get(hObject,'String')) returns contents of suvMapThrholdEdit as a double


% --- Executes during object creation, after setting all properties.
function suvMapThrholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to suvMapThrholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function toggleHiddenBasedCheckbox(checkbox, panel)
if get(checkbox,'Value')
   set(findall(panel, '-property', 'enable'), 'enable', 'on');
else
   set(findall(panel, '-property', 'enable'), 'enable', 'off');
end

function hiddenAllChildren(panel, status)
set(findall(panel, '-property', 'enable'), 'enable', status);


% --- Executes on button press in savedSuvImgBtn.
function savedSuvImgBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savedSuvImgBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory to store SUV imgs');
set(handles.savedSuvTxt, 'string', str);


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% check completely chosen mandatory fields
if ~checkChosenManFields(handles)
    return;
end

% prepare params and run "scr_fcn_run_all"
params = struct();
params.cur_path = get(handles.cur_path, 'string');
params.job_dir_path = get(handles.job_dir_path, 'string');
params.file_info = get(handles.file_info, 'string');
params.list_file = get(handles.listFileTxt, 'string');
params.steps = [0 0 0 0 1];
params.runOpt3 = 1;
params.savedSuv = get(handles.savedSuvTxt, 'string');

params.isSaveSuvMap = get(handles.SuvMapChBox, 'Value');
params.isSaveSuvThr = get(handles.SUVThCheckbox, 'Value');
params.isSaveSuvrThr = get(handles.SUVRThCheckbox, 'Value');

params.suvThreshold = str2double(get(handles.suvMapThrholdEdit, 'String'));
params.suvrThreshold = str2double(get(handles.suvrMapThrholdEdit, 'String'));

params.subList = handles.subList; % TODO: check
params.roiList = handles.roiList;

% temporaly disable "Run" button
% set(handles.runBtn, 'enable', 'off');

% call main function
[suv, suvall] = scr_fcn_run_all(params);

% save "suv, suvr" files
save(fullfile(params.savedSuv, ['SUV_' datestr(clock,'mmmm_dd_yyyy HH_MM')]), 'suv');
save(fullfile(params.savedSuv, ['SUVALL_' datestr(clock,'mmmm_dd_yyyy HH_MM')]), 'suvall');

% enable back "Run" button
set(handles.runBtn, 'enable', 'on');

% --- Check whether all mandatory fields chosen with valid values
function isOk = checkChosenManFields(handles)
isOk = false;

if ~checkManFieldsInLeft(handles)
    return;
end

if strcmp(get(handles.selRoiStt, 'String'), 'N/A')
    if strcmp(get(handles.doneBtn, 'enable'), 'on')
        warndlg(sprintf('Please click "Done" to finish LEFT side !'));
    else
        warndlg(sprintf('Please select ROIs at [7] !'));
    end
    return;
end

if strcmp(get(handles.selSubStt, 'String'), 'N/A')
    warndlg('Please select subjects needed analyzing at [8] !');
    return;
end

if isnan(str2double(get(handles.suvMapThrholdEdit, 'String')))
    warndlg('Please set SUV threshold as a NUMBER !');
    return;
end

if isnan(str2double(get(handles.suvrMapThrholdEdit, 'String')))
    warndlg('Please set SUVR threshold as a NUMBER !');
    return;
end

isOk = true;

function r = checkManFieldsInLeft(handles)
r = false;
if ~exist(get(handles.cur_path, 'String'), 'dir')
    warndlg('Please choose DIRECTORY included result images of step 1,2,3 and 4 at [1] !');
    return;
end

if ~exist(get(handles.job_dir_path, 'String'), 'dir')
    warndlg('Please choose DIRECTORY included job files at [2] !');
    return;
end

if ~exist(get(handles.file_info, 'String'), 'file')
    warndlg('Please choose Personal Info FILE (included Weight, Dosage, Time ...) at [3] !');
    return;
end

if ~exist(get(handles.aal_tpl_path, 'String'), 'file')
     warndlg('Please choose Template Definition FILE "ROI_MNI_V4.txt" at [4] !');
     return;
end

if ~exist(get(handles.listFileTxt, 'String'), 'file')
    warndlg('Please choose Matlab FILE defined details of images "list_file2.mat" at [5] !');
    return;
end

if ~exist(get(handles.savedSuvTxt, 'String'), 'dir')
    warndlg('Please choose DIRECTORY to save SUV images; SUV, SUVR along to threshold at [6] !');
    return;
end
r = true;


% --- Executes on button press in listFileBtn.
function listFileBtn_Callback(hObject, eventdata, handles)
% hObject    handle to listFileBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('.mat' ,'Select FILE list_file.mat');
str = fullfile ( path, file ); 
set(handles.listFileTxt, 'string', str);


% --- Executes on button press in dfSetFileBtn.
function dfSetFileBtn_Callback(hObject, eventdata, handles)
% hObject    handle to dfSetFileBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[str, filePath] = uigetfile('.txt' ,'Select default setting file (DEFAULT_SETTINGS.txt).');
str = fullfile(filePath, str);
if exist(str, 'file')
    t = readtable(str,'Delimiter','\t','ReadVariableNames',true);
    deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
    set(handles.cur_path, 'string', deftSet('cur_path'));
    set(handles.job_dir_path, 'string', deftSet('job_dir_path'));
    set(handles.file_info, 'string', deftSet('file_info'));
    set(handles.aal_tpl_path, 'string', deftSet('aal_tpl_path'));
    set(handles.listFileTxt, 'string', deftSet('list_file'));
    set(handles.savedSuvTxt, 'string', deftSet('savedSuv'));
end


% --- Executes on button press in selSubBtn.
function selSubBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selSubBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subfile = get(handles.listFileTxt,'string');
load(subfile);
temp = extractfield(list_file, 'name');
if isfield(handles, 'subList')
    init_vals = handles.subList;
else
    init_vals = 1;
end
if exist('list_file', 'var')
    [s,v] = listdlg('PromptString','Select subjects needed analyzing:',...
                'SelectionMode','multiple',...
                'ListString',temp,...
                'Name', 'Select subjects',...
                'ListSize',[200 300],...
                'InitialValue', init_vals);
end

if v % choose OK
    handles.subList = s;
    guidata(hObject,handles);
    set(handles.selSubStt,'String',sprintf('Done [%d]', length(s)));
end


% --- Executes on button press in SuvMapChBox.
function SuvMapChBox_Callback(hObject, eventdata, handles)
% hObject    handle to SuvMapChBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SuvMapChBox


% --- Executes on button press in selDirSavDefSetBtn.
function selDirSavDefSetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selDirSavDefSetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory to save above settings');
if exist(str, 'dir')
    handles.savDefSetDir = str;
    guidata(hObject,handles);
    set(handles.selDirSavDefSetStt, 'string', 'Done');
    set(handles.doneSavDefSetBtn, 'enable', 'on');
end


% --- Executes on button press in doneSavDefSetBtn.
function doneSavDefSetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to doneSavDefSetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = 'VAR_NAME\tVAR_VALUE\n';
s_strs = {get(handles.cur_path, 'string');...
    get(handles.job_dir_path, 'string');...
    get(handles.file_info, 'string');...
    get(handles.aal_tpl_path, 'string');...
    get(handles.listFileTxt, 'string');...
    get(handles.savedSuvTxt, 'string')};

s_strs = strrep(s_strs, '\', '\\');

str = [ str 'cur_path' '\t' s_strs{1,1} '\n'];
str = [ str  'job_dir_path' '\t' s_strs{2,1} '\n'];
str = [ str  'file_info' '\t' s_strs{3,1} '\n'];
str = [ str  'aal_tpl_path' '\t' s_strs{4,1} '\n'];
str = [ str 'list_file' '\t' s_strs{5,1} '\n'];
str = [ str  'savedSuv' '\t' s_strs{6,1} ];

fileName = fullfile(handles.savDefSetDir, 'DEFAULT_SETTINGS_5.txt');
fileID = fopen(fileName,'w');
fprintf(fileID,str);
fclose(fileID);
set(hObject,'enable','off');


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in defRoiBtn.
function defRoiBtn_Callback(hObject, eventdata, handles)
% hObject    handle to defRoiBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    % handles.roiListGui = [3:16, 19:28, 43:56, 59:68, 81,82, 85, 86, 89, 90 ];
    % numRoi = length(handles.roiListGui);
    % set(handles.selRoiStt, 'String', sprintf('Done [%d]', numRoi));
    selectRoiCalSuvBtn_Callback(hObject, eventdata, handles);
end
