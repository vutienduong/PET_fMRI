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

% Last Modified by GUIDE v2.5 02-Jun-2017 07:30:07

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

% set(findall(handles.roiPanel, '-property', 'enable'), 'enable', 'off');
set(findall(handles.step2Panel, '-property', 'enable'), 'enable', 'off');
% set(findall(handles.step3Panel, '-property', 'enable'), 'enable', 'off');
% % DEBUG


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
str = uigetdir('Select directory which involves ''extracted WM'' image');
set(handles.cur_path, 'string', str);
set(handles.cur_path, 'tooltipString', str);

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

% --- Executes on button press in doneBtn.
function doneBtn_Callback(hObject, eventdata, handles)
% hObject    handle to doneBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check completely Left side mandatory fields
if ~checkManFieldsInLeft(handles)
    return;
end

set(findall(handles.step2Panel, '-property', 'enable'), 'enable', 'on');
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
roifile = fullfile(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\ROI_MNI_V4.txt');
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
set(handles.savedSuvTxt, 'tooltipString', str);


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% check completely chosen mandatory fields
if ~checkChosenManFields(handles)
    return;
end

% prepare params and run "scr_fcn_run_all"
params = struct();
spmfold = scr_get_spm8_dir();
params.cur_path = get(handles.cur_path, 'string');
params.savedSuv = get(handles.savedSuvTxt, 'string');
params.job_dir_path = fullfile(spmfold, 'toolbox\pet_mri_tool\necessaryFiles');

params.isOnlyExcel = get(handles.onlyExcel, 'Value');
params.isOnlyMap = get(handles.onlySuvMap, 'Value');

params.isSaveSuvMap = get(handles.SuvMapChBox, 'Value');
params.isSaveSuvThr = get(handles.SUVThCheckbox, 'Value');
params.isSaveSuvrThr = get(handles.SUVRThCheckbox, 'Value');

params.suvThreshold = convertStr2Num(get(handles.suvMapThrholdEdit, 'String'));
params.suvrThreshold = convertStr2Num(get(handles.suvrMapThrholdEdit, 'String'));

params.subList = handles.subList; % TODO: check
params.roiList = handles.roiList;

if(get(handles.isSaveExcelTxt, 'Value'))
    params.isSaveExcel = 1;
end

% call main function
% MAIN FUNCTION
[~, ~] = scr_fcn_run_all_with_excel_cal_vol(params);

% enable back "Run" button
% set(findall(handles.step2Panel, '-property', 'enable'), 'enable', 'off');
% set(findall(handles.step3Panel, '-property', 'enable'), 'enable', 'on');

% --- Convert threshold string to NUMBER or an array of NUMBERs
function rs = convertStr2Num(str)
if strfind(str, ',')
    str = strsplit(str, ',');    
end
rs = str2double(str);

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

% if isnan(str2double(get(handles.suvMapThrholdEdit, 'String')))
if ~checkThreshInputValue(get(handles.suvMapThrholdEdit, 'String'))
    warndlg('Please set SUV threshold as a NUMBER or a list of NUMBER separating by comma ('','')!');
    return;
end

% if isnan(str2double(get(handles.suvrMapThrholdEdit, 'String')))
if ~checkThreshInputValue(get(handles.suvrMapThrholdEdit, 'String'))
    warndlg('Please set SUVR threshold as a NUMBER or a list of NUMBER separating by comma ('','')!');
    return;
end

isOk = true;

function r = checkThreshInputValue(str)
    if strfind(str, ',')
        split_str = strsplit(str, ',');
        for i =1:length(split_str)
            if isnan(str2double(split_str{1,i}))
                r = false;
                return;
            end
        end
    else
        r = ~isnan(str2double(str));
        return;
    end
    r = true;

function r = checkManFieldsInLeft(handles)
r = false;
if ~exist(get(handles.cur_path, 'String'), 'dir')
    warndlg('Please choose DIRECTORY included result images of step 1,2,3 and 4 at [1] !');
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
[str, filePath] = uigetfile('.txt' ,'Select default setting file (DEFAULT_SETTINGS5.txt).');
str = fullfile(filePath, str);
if exist(str, 'file')
    t = readtable(str,'Delimiter','\t','ReadVariableNames',true);
    deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
    set(handles.cur_path, 'string', deftSet('cur_path'));
    set(handles.savedSuvTxt, 'string', deftSet('savedSuv'));
end


% --- Executes on button press in selSubBtn.
function selSubBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selSubBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    load(fullfile(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\tempListFile.mat'));
    % temp = extractfield(list_file, 'name');
    temp = {list_file(:).name};
    if isfield(handles, 'subList')
        init_vals = handles.subList;
    else
        init_vals = 1;
    end
    [s,v] = listdlg('PromptString','Select subjects needed analyzing:',...
                'SelectionMode','multiple',...
                'ListString',temp,...
                'Name', 'Select subjects',...
                'ListSize',[200 300],...
                'InitialValue', init_vals);

    if v % choose OK
        handles.subList = s;
        guidata(hObject,handles);
        set(handles.selSubStt,'String',sprintf('Done [%d]', length(s)));
    end
catch
    warndlg('Please run step [Multi subject I] first.');
    return;
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
try
    strdir = uigetdir('Select directory to save above settings');
    if exist(strdir, 'dir')
%         handles.savDefSetDir = str;
%         guidata(hObject,handles);
        str = 'VAR_NAME\tVAR_VALUE\n';
        s_strs = {get(handles.cur_path, 'string'); get(handles.savedSuvTxt, 'string')};
        s_strs = strrep(s_strs, '\', '\\');

        str = [ str 'cur_path' '\t' s_strs{1,1} '\n'];
        str = [ str 'savedSuv' '\t' s_strs{2,1} ];

        fileName = fullfile(strdir, 'DEFAULT_SETTINGS_5.txt');
        fileID = fopen(fileName,'w');
        fprintf(fileID,str);
        fclose(fileID);
        set(hObject,'enable','off');
        set(handles.selDirSavDefSetStt, 'string', 'Done');
    end
catch
    warndlg('Please select valid folder to save above setting.');
    return;
end

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


% --- Executes on button press in saveExcelBtn.
function saveExcelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveExcelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.isSaveExcelTxt, 'Value', 1);
runBtn_Callback(hObject, eventdata, handles);



% --- Executes on button press in onlyExcel.
function onlyExcel_Callback(hObject, eventdata, handles)
% hObject    handle to onlyExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onlyExcel


% --- Executes on button press in onlySuvMap.
function onlySuvMap_Callback(hObject, eventdata, handles)
% hObject    handle to onlySuvMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onlySuvMap
