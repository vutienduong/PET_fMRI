function [varargout] = scr_fcn_run_all_with_excel(guiParams)
% New method: 1. Coreg, 2. Segment, 3. Matching, 4. Inv Norm
% Use Excel file as patient info (name, weight, dosage, half_life, time),
% file info (MRI, PET name)
% Set directory inclusdes all processed files

mapStt = scr_get_Status();
cur_path = guiParams.cur_path;
patt = '*.img';
tail = ',1';
suv = 1; % Fake
suvall = 1; % Fake
if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end

% [1] Read information from Excel file.
try
    [~,~,raw_si] = xlsread(guiParams.scaninfo.filename, guiParams.scaninfo.sheet);
    idx = guiParams.scaninfo.cols;
    list_file = struct();
    colHeadings = {'name', 'mri', 'pet', 'weight', 'dosage', 'time', 'half_life'};
    if guiParams.scaninfo.setCol('header') == 1
        raw_si = raw_si(2:end, cell2mat(idx));
    else
        raw_si = raw_si(:, cell2mat(idx));
    end
    v = cell(size(raw_si,1),1);
    v(:) = {6500};
    raw_si = [raw_si, v];
    list_file = cell2struct(raw_si, colHeadings, 2);
catch
    warndlg('Can not read Excel file with specified sheet. Please check sheet index or Excel file is correct ?!'); 
    return;
end


%% [2] Check how many subject files available as in excel file with PET-MRI
% folder
%% [2.1] Check if file name is included in PET name or MRI name lists
% Require fields: pet, mri
file_fold = guiParams.cur_path;
files = dir(file_fold);
pos_idx = []; % list of indexes of matched subjects
for i =3:length(files)
    fname = files(i).name;
    % check if this file is a .img file
    if (strcmp(fname(end-3:end), '.img'))
        % check in list MRI name
        tmatch = strmatch(fname, {list_file.mri},'exact');
        if tmatch
            pos_idx = [pos_idx tmatch];
            continue;
        end
        
        % check in list PET name
        tmatch = strmatch(fname, {list_file.pet},'exact');
        if tmatch
            pos_idx = [pos_idx tmatch];
        end
    end
end

pos_idx = unique(pos_idx); % remove 2x of an index
if isempty(pos_idx)
    warndlg('PET-MRI folder does not include files of subjects as describing in Excel file.');
    return;
end
list_file = list_file(pos_idx);
nrun = length(list_file);

%% [2.2] Check if file name starts with 'subject_name' as in Excel file, then check 'sag'=> mri or 'ptct'=> pet
% Require field: name, Status: TODO

%% [3] Notice available subject files

% [4] Run with available subject files


% Set directory of job files
job_dir_path = guiParams.job_dir_path;

if isfield(guiParams, 'aal_file') % step 1,2,3,4
    copyfile( guiParams.aal_file , fullfile(cur_path, 'ROI_MNI_V4.nii'));
end

% Mutable setting
if isfield(guiParams, 'binThresh') % step 1,2,3,4
    THRESHOLD = guiParams.binThresh;
else
    THRESHOLD = 0.3; % default
end
STEPS = guiParams.steps; %[0 0 0 0 1];
IS_SAVE_EXCEL = isfield(guiParams, 'isSaveExcel');
approach = guiParams.approach; % 1: new, 2: old

%% ==================STEP 1: coregister PET -> MRI==================
if approach == 2 % OLD
    jobfile = {fullfile(job_dir_path, 'step1_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(3, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).mri tail])};
        new_tpl_name = [list_file(crun).name 'ROI_MNI_V4.nii'];
        copyfile(fullfile(cur_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
        inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
        inputs{3, crun} = {fullfile(cur_path, [new_tpl_name tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});

    % delete unecesssary ROI_MNI files
    for crun = 1:nrun
        delete(fullfile(cur_path, [list_file(crun).name 'ROI_MNI_V4.nii']));
    end
    
else % NEW
    jobfile = {fullfile(job_dir_path, 'step1_1_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).mri tail])};
        inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});    
end
disp('===========FINISH STEP 1: Coregister PET to MRI ===========');

%% ==================STEP 2: segment MRI==================
jobfile = {fullfile(job_dir_path, 'step2_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = {fullfile(cur_path, [list_file(crun).mri tail])};
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
disp('===========FINISH STEP 2: Segment MRI ===========');

%% ==================STEP 3: matching==================
saved_prefix = 'm_'; % wm_ext_, i_wm_ext
is_inverse = 1;
mask_prefix = 'c2'; % c1: gm, c2: wm
for crun = 1:nrun
    pet_file = fullfile(cur_path, ['r' list_file(crun).pet tail]);
    mask_file = fullfile(cur_path, [ mask_prefix list_file(crun).mri tail]);
    scr_masking_pet(pet_file, mask_file, THRESHOLD, is_inverse, saved_prefix);
end
disp('===========FINISH STEP 3===========');

%% ==================STEP 4: ROI_MNI -> MRI ==================
if approach == 2 % OLD: coregister ROI_MNI -> MRI
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).mri tail])};
        new_tpl_name = [list_file(crun).name 'ROI_MNI_V4.nii'];
        inputs{2, crun} = {fullfile(cur_path, ['r' new_tpl_name tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========FINISH STEP 3.1===========');
    
else % NEW: Inversely normalized ROI_MNI -> MRI
    jobfile = {fullfile(job_dir_path, 'inv_norm_job.m')};
    inputs = cell(2, nrun);
    for crun = 1:nrun
        new_tpl_name = ['ROI_MNI_V4' list_file(crun).name '.nii'];
        copyfile(fullfile(job_dir_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).mri(1:end-4) '_seg_inv_sn.mat'])}; % mat name
        inputs{2, crun} = {fullfile(cur_path, [new_tpl_name tail])};
    end

    jobs = repmat(jobfile, 1, nrun);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 4: Inverse Normalization ===========');
end
return; % TODO: debug
%% ==================STEP 5: calculate SUV, SUVR==================
if STEPS(5) && ~IS_SAVE_EXCEL
    load ROI_MNI_V4_List.mat;
    load ROI_MNI_V4_Border.mat;
    suv = struct();
    t = readtable(guiParams.file_info,'Delimiter','\t','ReadVariableNames',true);
    params = table2struct(t);
    
    scanInd = []; % use to store index of subject in scaninfo file
    keep_idx = []; % use to keep index of "actually existed subjects" among selected subjects in folder
    for crun = 1:length(list_file)
        if exist(fullfile(cur_path, ['m_r' list_file(crun).pet]), 'file') == 2
            tempInd = find(strcmp({params.name}, list_file(crun).name));
            scanInd = [scanInd tempInd];
            keep_idx = [keep_idx crun];
            disp(['Pet file of subject ' list_file(crun).name ' exist for analysis']);
        end
    end
    
    list_file = list_file(keep_idx);
    nrun = length(list_file);
    if nrun == 0 % no pet files of selected subjects exist in specified folder
        disp('[ERROR] NO ANY PET IMAGES OF SELECTED SUBJECTS FOUND, STOP PROGRAM !');
        return; 
    end
    
    params = params(scanInd);
    old_savedSuv = guiParams.savedSuv;
    tempSuvThr = 0.5;
    guiParams.savedSuv = [old_savedSuv num2str(guiParams.suvrThreshold)];
    if exist(guiParams.savedSuv, 'dir') ~= 7
        mkdir(guiParams.savedSuv);
    end
    
    disp([ 'Run for SUVR thresh: ' num2str(guiParams.suvrThreshold)]);
    disp([ 'Run for SUV thresh: ' num2str(guiParams.suvThreshold)]);
    tempSuvThr = tempSuvThr + 0.2;
    for crun = 1:nrun
        pet_img = list_file(crun).pet;
        pet_hdr = [pet_img(1:(end-3)) 'hdr'];
        
        % 1. version with m_r
%         GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ',1']);
%         rTpl_img = fullfile(cur_path, ['rr' list_file(crun).name, 'ROI_MNI_V4.nii,1']);

        % 2. version for no sub
%         GM_PET_img = fullfile(cur_path, ['rm_r' pet_hdr ',1']);
%         rTpl_img = fullfile(cur_path, 'ROI_MNI_V4.nii,1');

        % 3. new version with Inverse Norm (5*)
        rTpl_img = fullfile(cur_path, ['wROI_MNI_V4' list_file(crun).name '.nii,1']);
        % a) for non extract
%         GM_PET_img = fullfile(cur_path, ['r' pet_hdr ',1']); % use 'r' for register
        GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ',1']); % use 'r' for register
        
        % b) for wm extract, thr = 0.7
%         IWM_PET_folder = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\WM extracted\thresh 0\iwm_ext';
%         GM_PET_img = fullfile(IWM_PET_folder, ['iwm_ext_r' pet_hdr ',1']); 
        
        % c) for gm extract, thr = 0.7
%         GM_PET_folder = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\GM mask\thresh 0_7\gm_ext';
%         GM_PET_img = fullfile(GM_PET_folder, ['gm_ext_r' pet_hdr ',1']);
        
        % 3.1 new version with Inverse Norm, MNI STANDARD SPACE (4*)
        % 3.1.1 ROI_MNI_V4 (79 x 95 x68) template type
%         rTpl_img = fullfile(job_dir_path, 'Temp folder', 'wROI_MNI_V4_along_mri.nii,1'); % 3.1.1 i) along MRI
%         rTpl_img = fullfile(job_dir_path, 'Temp folder', 'wROI_MNI_V4_along_pet.nii,1'); % 3.1.1 i) along PET
%         rTpl_img = fullfile(job_dir_path, 'Temp folder', 'wROI_MNI_V4_as_inv_mri_segment.nii,1'); % 3.1.1 i) along T1.nii segment
        
        % a) for gm extract, thr = 0.7
%         GM_PET_folder = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\GM mask\thresh 0_7\wgm_ext';
%         GM_PET_img = fullfile(GM_PET_folder, ['wgm_ext_r' pet_hdr ',1']);
        
        % b)for iwm extract, thr = 0.7
%         GM_PET_folder = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\WM extracted\thresh 0_7\wiwm_ext';
%         GM_PET_img = fullfile(GM_PET_folder, ['wiwm_ext_r' pet_hdr ',1']);
        

        disp(['...run subject ', list_file(crun).name]);
        guiParams.subName = list_file(crun).name;
        suvValue = scr_func2(GM_PET_img, rTpl_img, ROI, params(crun), guiParams);
        if isstruct(suvValue) && isfield(suvValue, 'SUV_max')
            suv(crun).name = list_file(crun).name;
            suv(crun).value = suvValue;
        end
        disp('Done ...');
    end
    disp('[SUCCESS] FINISH STEP 5 CALCULATE SUV, SUVR ...');
end
% end

% WRITE to excel file
if IS_SAVE_EXCEL
    % check selected subjects
%     list_file = list_file(guiParams.subList); % cut down list file to selected subjects
    keep_idx = []; % use to keep index of "actually existed subjects" among selected subjects in folder
    for crun = 1:length(list_file)
        if exist(fullfile(cur_path, ['m_r' list_file(crun).pet]), 'file') == 2
            keep_idx = [keep_idx crun];
            disp(['Pet file of subject ' list_file(crun).name ' exist for analysis']);
        end
    end
    list_file = list_file(keep_idx);
    
    nrun = length(list_file);
    if nrun == 0 % no pet files of selected subjects exist in specified folder
        disp('[ERROR] NO ANY PET IMAGES OF SELECTED SUBJECTS FOUND, STOP PROGRAM !');
        return; 
    end
    
    guiParams.savedSuv = [guiParams.savedSuv num2str(guiParams.suvrThreshold)];
    % write to Excel
    try
        scr_write_to_Excel(guiParams.savedSuv, list_file);
        scr_write_to_ExcelSUV(guiParams.savedSuv, list_file);
    catch
        warning('PROBLEM WITH XLSWRITE. DONT WORRY, TRY TO RUN SEVERAL TIMES ! ! !');
    end
end

if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end