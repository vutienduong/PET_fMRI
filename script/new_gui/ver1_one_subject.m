function varargout = ver1_one_subject(varargin)
% VER1_ONE_SUBJECT MATLAB code for ver1_one_subject.fig
%      VER1_ONE_SUBJECT, by itself, creates a new VER1_ONE_SUBJECT or raises the existing
%      singleton*.
%
%      H = VER1_ONE_SUBJECT returns the handle to a new VER1_ONE_SUBJECT or the handle to
%      the existing singleton*.
%
%      VER1_ONE_SUBJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VER1_ONE_SUBJECT.M with the given input arguments.
%
%      VER1_ONE_SUBJECT('Property','Value',...) creates a new VER1_ONE_SUBJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ver1_one_subject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ver1_one_subject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ver1_one_subject

% Last Modified by GUIDE v2.5 25-Jun-2017 17:33:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ver1_one_subject_OpeningFcn, ...
                   'gui_OutputFcn',  @ver1_one_subject_OutputFcn, ...
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


% --- Executes just before ver1_one_subject is made visible.
function ver1_one_subject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ver1_one_subject (see VARARGIN)

% Choose default command line output for ver1_one_subject
handles.output = hObject;

str = 'history_default.txt';
if exist(str, 'file')
    t = readtable(str,'Delimiter','\t','ReadVariableNames',true);
    try
        deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
        set(handles.selMriSttTxt, 'string', 'OK');
        set(handles.selMriSttTxt, 'tooltipString', deftSet('mri_file'));
        
        set(handles.selPetSttTxt, 'string', 'OK');
        set(handles.selPetSttTxt, 'tooltipString', deftSet('pet_file'));
        
        set(handles.selSavedSuvFoldTxt, 'string', 'OK');
        set(handles.selSavedSuvFoldTxt, 'tooltipString', deftSet('saved_suv_fold'));
        
        set(handles.binThreshTxt, 'string', deftSet('bin_thresh'));
        set(handles.subNameTxt, 'string', deftSet('subject_name'));
        set(handles.bodyWeightTxt, 'string', deftSet('body_weight'));
        set(handles.DosageTxt, 'string', deftSet('dosage'));
        set(handles.timeTxt, 'string', deftSet('time'));
    catch
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ver1_one_subject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ver1_one_subject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selMriBtn.
function selMriBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selMriBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    str = spm_select(1,'image','Select MRI image');
    set(handles.selMriSttTxt, 'string', 'OK');
    set(handles.selMriSttTxt, 'tooltipString', str);
    
    slash_index = strfind(str, '\');
    file_name = str(slash_index(end)+1: end);
    
    underscore_index = strfind(file_name, '_');
    search_name = file_name(1:(underscore_index(3)-1));
    set(handles.subNameTxt, 'string', search_name);
catch
    set(handles.errorTxt, 'string', 'Error!!! Please re-select MRI image again');
end



% --- Executes on button press in selPetBtn.
function selPetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selPetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    str = spm_select(1,'image','Select PET image');
    set(handles.selPetSttTxt, 'string', 'OK');
    set(handles.selPetSttTxt, 'tooltipString', str);
catch
    set(handles.errorTxt, 'string', 'Error!!! Please re-select PET image again');
end



function binThreshTxt_Callback(hObject, eventdata, handles)
% hObject    handle to binThreshTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of binThreshTxt as text
%        str2double(get(hObject,'String')) returns contents of binThreshTxt as a double


% --- Executes during object creation, after setting all properties.
function binThreshTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binThreshTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selSpmBtn.
function selSpmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selSpmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    str = spm_select(1,'dir','Select SPM8 folder in PC');
catch
    set(handles.errorTxt, 'string', 'Error!!! Please re-select SPM folder again');
end



function subNameTxt_Callback(hObject, eventdata, handles)
% hObject    handle to subNameTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subNameTxt as text
%        str2double(get(hObject,'String')) returns contents of subNameTxt as a double


% --- Executes during object creation, after setting all properties.
function subNameTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subNameTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selSavedSuvFoldBtn.
function selSavedSuvFoldBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selSavedSuvFoldBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    str = spm_select(1,'dir','Select folder to save Export file (excel)');
    set(handles.selSavedSuvFoldTxt, 'string', 'OK');
    set(handles.selSavedSuvFoldTxt, 'tooltipString', str);
catch
    set(handles.errorTxt, 'string', 'Error!!! Please re-select folder');
end



% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try
    % 1. Check all field are filled
    if checkValidFields(handles)
        return;
    end
    % 2. Save to history_default.txt
    saveHistoryDefaultSetting(handles, '');

    % 3. Prepare params and run "scr_fcn_run_all"
    params = struct();
    curPath = get(handles.selMriSttTxt, 'tooltipString');
    slashFindIdx = strfind(curPath, '\');
    params.cur_path = curPath(1: slashFindIdx(end) -1);

    params.job_dir_path = fullfile(scr_get_spm8_dir(), '\toolbox\aal\necessaryFiles');
    params.savedSuv = get(handles.selSavedSuvFoldTxt, 'tooltipString');
    params.mri = get(handles.selMriSttTxt, 'tooltipString');
    params.pet = get(handles.selPetSttTxt, 'tooltipString');
    params.subject_name = get(handles.subNameTxt, 'string');
    
    params.aal_file = fullfile( params.job_dir_path,'ROI_MNI_V4.nii');

    file_info = struct();
    file_info.time = get(handles.timeTxt, 'string');
    file_info.half_life = get(handles.halfLifeTxt, 'string');
    file_info.weight = get(handles.bodyWeightTxt, 'string');
    file_info.dosage = get(handles.DosageTxt, 'string');

    params.file_info = file_info;
    params.binThresh = str2num(get(handles.binThreshTxt, 'string'));
    params.approach = get(handles.popupmenu1, 'value'); % default is 2
    setNotify(handles, '[INFO] RUNNING');
    

    % params.isSaveSuvMap = get(handles.SuvMapChBox, 'Value');
    % params.isSaveSuvThr = get(handles.SUVThCheckbox, 'Value');
    % params.isSaveSuvrThr = get(handles.SUVRThCheckbox, 'Value');
    % 
    % params.suvThreshold = str2double(get(handles.suvMapThrholdEdit, 'String'));
    % params.suvrThreshold = str2double(get(handles.suvrMapThrholdEdit, 'String'));
    % 
    % params.subList = handles.subList; % TODO: check
    % params.roiList = handles.roiList;

    scr_fcn_run_one_subject(params);
% catch
%     set(handles.errorTxt, 'string', 'Some errors happen');
% end

function saveHistoryDefaultSetting(handles, str)
str = 'VAR_NAME\tVAR_VALUE\n';
s_strs = {get(handles.selMriSttTxt, 'tooltipString');...
    get(handles.selPetSttTxt, 'tooltipString');...
    get(handles.selSavedSuvFoldTxt, 'tooltipString');...

    get(handles.binThreshTxt, 'string');...
    get(handles.subNameTxt, 'string');...
    get(handles.bodyWeightTxt, 'string');...
    get(handles.DosageTxt, 'string');...
    get(handles.timeTxt, 'string')};

s_strs = strrep(s_strs, '\', '\\');

var_name_arr = {'mri_file', 'pet_file', 'spm_fold', 'saved_suv_fold', ...
    'bin_thresh', 'subject_name', 'body_weight', 'dosage'};
for i =1:length(var_name_arr)
    str = [ str var_name_arr{1,i} '\t' s_strs{i,1} '\n'];
end
str = [ str  'time' '\t' s_strs{9,1} '\n'];

fileName = fullfile(get(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\history_default.txt'));
fileID = fopen(fileName,'w');
fprintf(fileID,str);
fclose(fileID);

function v = checkValidFields(handles)
all_errors = struct();
all_errors.miss_mri_file = 'Error!!! Please select MRI file';
all_errors.miss_pet_file = 'Error!!! Please select PET file';
all_errors.miss_saved_suv_fold = 'Error!!! Please select folder to save suv file';
all_errors.miss_spm_fold = 'Error!!! Please select spm8 folder';
all_errors.miss_bin_thresh = 'Error!!! Please select threshold to extract White matter ';
all_errors.beyond_range = 'Error!!! WM threshold must be in range [0,1]';
all_errors.miss_subject_name = 'Error!!! Please fill subject name';
all_errors.miss_body_weight = 'Error!!! Please fill body weight info';
all_errors.miss_half_life = 'Error!!! Please fill half life info';
all_errors.miss_dosage = 'Error!!! Please fill dosage info';
all_errors.miss_time = 'Error!!! Please fill time info';

v = 1;
if isempty(get(handles.selMriSttTxt, 'tooltipString'))
    set(handles.errorTxt, 'string', all_errors.miss_mri_file);
    return;
end

if isempty(get(handles.selPetSttTxt, 'tooltipString'))
    set(handles.errorTxt, 'string', all_errors.miss_pet_file);
    return;
end

if isempty(get(handles.selSavedSuvFoldTxt, 'tooltipString'))
    set(handles.errorTxt, 'string', all_errors.miss_saved_suv_fold); return;
end

bin_thresh_value = get(handles.binThreshTxt, 'string');
if isempty(str2num(bin_thresh_value))
    set(handles.errorTxt, 'string', all_errors.miss_bin_thresh); return;
elseif str2num(bin_thresh_value) > 1 || ...
        str2num(bin_thresh_value) < 0
    set(handles.errorTxt, 'string', all_errors.beyond_range); return;
end

if isempty(get(handles.subNameTxt, 'string'))
    set(handles.errorTxt, 'string', all_errors.miss_subject_name); return;
end

if isempty(str2num(get(handles.bodyWeightTxt, 'string')))
    set(handles.errorTxt, 'string', all_errors.miss_body_weight); return;
end

if isempty(str2num(get(handles.DosageTxt, 'string')))
    set(handles.errorTxt, 'string', all_errors.miss_dosage); return;
end

if isempty(str2num(get(handles.halfLifeTxt, 'string')))
    set(handles.errorTxt, 'string', all_errors.miss_half_life); return;
end

if isempty(str2num(get(handles.timeTxt, 'string')))
    set(handles.errorTxt, 'string', all_errors.miss_time); return;
end
v = 0;

function setNotify(handles, content)
set(handles.errorTxt, 'string', content);
set(handles.errorTxt, 'foregroundColor', 'blue');


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
% 
% contents = cellstr(get(hObject,'String'));
selectedItem = {get(hObject,'Value')};
selectedIdx = selectedItem{1,1};
explainStr = scr_get_setting('explain_method_new_old');
% explainStr{1,1} = 'Step 1: Coregister PET to MRI -> rPET, \n Step 2: Segment MRI -> WM, GM .... \n Step 3: Matching WM to rPET -> m_rPET ... \n Step 4: Inversely normalizing AAL temp to MRI -> rROI_MNI_V4';
% explainStr{2,1} = 'Step 1: Coregister PET to MRI along with AAL -> rPET, rAAL, \n Step 2: Segment MRI -> WM, GM .... \n Step 3: Matching WM to rPET -> m_rPET ... \n Step 4: Coregister rAAL temp to MRI -> rrAAL';

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


% --- Executes during object creation, after setting all properties.
function explainMethodTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to explainMethodTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
