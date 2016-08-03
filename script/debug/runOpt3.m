function varargout = runOpt3(varargin)
% RUNOPT3 MATLAB code for runOpt3.fig
%      RUNOPT3, by itself, creates a new RUNOPT3 or raises the existing
%      singleton*.
%
%      H = RUNOPT3 returns the handle to a new RUNOPT3 or the handle to
%      the existing singleton*.
%
%      RUNOPT3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNOPT3.M with the given input arguments.
%
%      RUNOPT3('Property','Value',...) creates a new RUNOPT3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runOpt3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runOpt3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runOpt3

% Last Modified by GUIDE v2.5 28-Apr-2016 13:45:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runOpt3_OpeningFcn, ...
                   'gui_OutputFcn',  @runOpt3_OutputFcn, ...
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


% --- Executes just before runOpt3 is made visible.
function runOpt3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runOpt3 (see VARARGIN)

% Choose default command line output for runOpt3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runOpt3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runOpt3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in selSuvFiles.
function selSuvFiles_Callback(hObject, eventdata, handles)
% hObject    handle to selSuvFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, pathstr] = uigetfile('.mat' ,'Select SUV files','MultiSelect', 'on' );
if isfield(handles, 'listfile')
    listfile = handles.listfile;
else
    listfile = cell(0);
end

if iscell(file)
    for i=1:length(file)
        listfile{length(listfile)+1,1} = fullfile(pathstr, file{1,i});
    end
else
    listfile{length(listfile)+1,1} = fullfile(pathstr, file);
end

listfile = unique(listfile);
dispStr = '';
for i=1:length(listfile)
   % dispStr = [dispStr '\n ' listfile{i,1}(end-15:end)];
   [~,name,ext] = fileparts(listfile{i,1});
   dispStr = sprintf('%s%s \n %s ', name, ext, dispStr);
end
set(handles.numFiles, 'String', num2str(length(listfile)));
set(handles.listSuvFilesTxt, 'String', dispStr);
handles.listfile = listfile;
guidata(hObject,handles);


% --- Executes on button press in runBtn.
function runBtn_Callback(hObject, eventdata, handles)
% hObject    handle to runBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check completely chosen mandatory fields
if ~checkChosenManFields(handles)
    return;
end
listfile = handles.listfile;
suv = struct();
for i=1:length(listfile)
    [~,name,~] = fileparts(listfile{i,1});
    load(listfile{i,1});
    suv(i).name = name;
    eval(sprintf('suv(i).value = %s;', name));
    eval(sprintf('clear %s;', name));
end

% create fake list_file
list_file = scr_func_make_fake_List_file( listfile );
suvall = scr_func_opt3_analyze( suv, list_file );
savedSuv = get(handles.savPthTxt, 'string');
save(fullfile(savedSuv, ['SUVALL_' datestr(clock,'mmmm_dd_yyyy HH_MM')]), 'suvall');
disp('======');
disp('Done');
disp('======');

function isOk = checkChosenManFields(handles)
isOk = false;
if str2double(get(handles.numFiles, 'String')) == 0
    warndlg('Please choose AT LEAST one SUV Matlab FILES !');
    return;
end

if ~exist(get(handles.savPthTxt, 'String'), 'dir')
    warndlg('Please choose DIRECTORY to save Analyzed result !');
    return;
end
isOk = true;

% --- Executes on button press in savPthBtn.
function savPthBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savPthBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = spm_select(1,'dir','Select directory to save analyzed result');
set(handles.savPthTxt, 'string', str);


% --- Executes during object creation, after setting all properties.
function savPthTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savPthTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
