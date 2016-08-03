% clear;

% Find all files which has extension path is .img
cur_path= spm_select(1,'dir','Select directory which involves PET image');
patt = '*.img';
tail = ',1';
% cur_path = pwd;

% Select directory of job files
job_dir_path= spm_select(1,'dir','Select directory which involves involve job files');

% Default parameter values
DEFL_WEIGHT     =   60;
DEFL_DOSE       =   400;
DEFL_TIME       =   60;
DEFL_HALFLIFE   =   6500;

% Mutable setting
THRESHOLD = 0.3;
CREATE_LIST = false;
STEPS = [0 0 0 0 0];
CAL_AVG_SUVR = false;



% ==================STEP 0: CREATE LIST OF FILE INFO =================
if CREATE_LIST
    list_file = struct(); % include fmri and pet fields in each element
    list = dir(patt); % NOTE: current directory
    j = 1;
    while ~isempty(list)
        temp = list(1).name;
        list_file(j).fmri = temp; % always fmri file occurs first in list
        list(1) = []; % remove considering element
        underscore_index = strfind(temp, '_');
        search_name = temp(1:(underscore_index(3)-1));
        list_file(j).name = search_name;
        for i=1:length(list)
            if ~isempty(strfind(search_name,'_'))
                list_file(j).pet = list(i).name;
                list(i) = [];
                break;
            end
        end
        j = j +1;
    end
end
nrun = length(list_file);

% Create initially job file to use for all subjects
jobfile1 = {fullfile(job_dir_path, 'step1_job.m')};
jobfile2 = {fullfile(job_dir_path, 'step2_job.m')};
jobfile3 = {fullfile(job_dir_path, 'step3_job.m')};
jobs1 = repmat(jobfile1, 1, 1);
jobs2 = repmat(jobfile2, 1, 1);
jobs3 = repmat(jobfile3, 1, 1);
inputs1 = cell(3, 1);
inputs2 = cell(1, 1);
inputs3 = cell(2, 1);

% Load ROI map for step 4
load ROI_MNI_V4_List.mat;
load ROI_MNI_V4_Border.mat;

% Create variables used for all subjects
suv = struct();
params = struct();

% Create folder 'suv' to store all suv values
mkdir(cur_path, 'suv');

% FORM to set parameters for calculation SUV
% prompt = {'Subject weight (kg)', 'Dosage (Mbq)', 'time (minutes)', 'half_life (seconds)'};
% dlg_title = 'Specify SUV parameter values';
% num_lines = 1;
% def = {'60','400','60','6500'};
% answer = inputdlg(prompt,dlg_title,num_lines,def);

% Assign default parameter values
params.weight       =   DEFL_WEIGHT; % TODO
params.dose         =   DEFL_DOSE; 
params.time         =   DEFL_TIME; 
params.half_life    =   DEFL_HALFLIFE;

% Run process for all subjects
for sub_idx =1:nrun
	%==================STEP 1: coregister PET -> MRI==================
    new_tpl_name = [list_file(sub_idx).name 'ROI_MNI_V4.nii'];
    copyfile(fullfile(cur_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
	inputs1{1, 1} = {fullfile(cur_path, [list_file(sub_idx).fmri tail])};
	inputs1{2, 1} = {fullfile(cur_path, [list_file(sub_idx).pet tail])};
    inputs1{3, 1} = {fullfile(cur_path, [new_tpl_name tail])};
	spm('defaults', 'FMRI');
	spm_jobman('serial', jobs1, '', inputs1{:});
    
    % delete unecesssary ROI_MNI files
    delete(fullfile(cur_path, [list_file(sub_idx).name 'ROI_MNI_V4.nii']));

	%==================STEP 2: segment MRI==================
	inputs2{1, 1} = {fullfile(cur_path, [list_file(sub_idx).fmri tail])};
	spm('defaults', 'FMRI');
	spm_jobman('serial', jobs2, '', inputs2{:});

	%==================STEP 3: matching==================
	WM_img = fullfile(cur_path, ['c2' list_file(sub_idx).fmri tail]);
	rPET_img = fullfile(cur_path, ['r' list_file(sub_idx).pet tail]);
	scr_func1(WM_img, rPET_img);

	%==================STEP 3.1: coregister ROI_MNI -> MRI==================
	inputs3{1, 1} = {fullfile(cur_path, [list_file(sub_idx).fmri tail])};
    inputs3{2, 1} = {fullfile(cur_path, ['r' list_file(crun).name 'ROI_MNI_V4.nii' tail])};
	spm('defaults', 'FMRI');
	spm_jobman('serial', jobs1, '', inputs3{:});

	%==================STEP 4: calculate SUV, SUVR==================
	pet_img = list_file(sub_idx).pet;
	pet_hdr = [pet_img(1:(end-3)) 'hdr'];
	GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ]);
	rTpl_img = fullfile(cur_path, ['rr' list_file(sub_idx).name 'ROI_MNI_V4.nii']);
	suv(sub_idx).name = list_file(sub_idx).name;
	temp_suv = scr_func2(GM_PET_img, rTpl_img, ROI, params);
	suv(sub_idx).value = temp_suv;
	
	% Save SUV file
	suv_file = fullfile(cur_path, 'suv', [list_file(sub_idx).name '_suv.mat']);
	save(suv_file);
    
    % Display successful run for this subject
    disp(['**Run Success: ' suv(sub_idx).name]);
end

% thu muc chua tat ca file goc f1
% thu muc chua tat ca cac job file
% threshold
% thu muc chua file ROI MNI
% thu muc chua log