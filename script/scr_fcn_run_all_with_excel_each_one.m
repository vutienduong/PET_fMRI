function [varargout] = scr_fcn_run_all_with_excel_each_one(guiParams)
% New method: 1. Coreg, 2. Segment, 3. Matching, 4. Inv Norm
% Old method: 1. Coreg (include ROI_MNI_V4), 2. Segment, 3. Matching, 4.
% Coreg
% Run each subject for 4 step, then repeat for another subject
% Use Excel file as patient info (name, status, mri_name, pet_name, weight, dosage, time)

% Set directory inclusdes all processed files
cur_path = guiParams.cur_path;
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
    colHeadings = {'name', 'status', 'mri', 'pet', 'weight', 'dosage', 'time', 'half_life'};
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

% save list_file, approach to 'necessaryFiles/tempListFile.mat' to use in step 2 (no
% need to read Excel file again)
approach = guiParams.approach; % 1: new, 2: old
save(fullfile(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\tempListFile.mat'), 'list_file', 'approach');

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

log_file = fullfile(cur_path, 'log_pet_mri.txt');
scr_write_log(log_file, 'Start', 'w');
hwait = waitbar(0,'Start', 'Name', sprintf('Progress of %d subjects', nrun));
for crun = 1:nrun
    %% ==================STEP 1: coregister PET -> MRI==================
    waitbar((crun-1)/nrun,hwait,sprintf('Done %d / %d subjects, Current: %s',crun-1,nrun, list_file(crun).name));
    mri = list_file(crun).mri;
    pet = list_file(crun).pet;
    sname = list_file(crun).name;
    hwait2 = waitbar(0,'Coregister PET to MRI', 'Name', sprintf('Run 4 steps of subject %s', sname));
    try
        if approach == 2 % OLD
            jobfile = {fullfile(job_dir_path, 'step1_job.m')};
            inputs = cell(3, 1);
            inputs{1, 1} = {fullfile(cur_path, [mri tail])};
            new_tpl_name = fullfile(cur_path,[sname 'ROI_MNI_V4.nii']);
            copyfile(fullfile(cur_path, 'ROI_MNI_V4.nii') , new_tpl_name);
            inputs{2, 1} = {fullfile(cur_path, [pet tail])};
            inputs{3, 1} = {[new_tpl_name tail]};
            spm('defaults', 'FMRI');
            spm_jobman('serial', jobfile, '', inputs{:});
            % delete unecesssary ROI_MNI file
            delete(new_tpl_name);

        else % NEW
            jobfile = {fullfile(job_dir_path, 'step1_1_job.m')};
            inputs = cell(2, 1);
            inputs{1, 1} = {fullfile(cur_path, [mri tail])};
            inputs{2, 1} = {fullfile(cur_path, [pet tail])};
            spm('defaults', 'FMRI');
            spm_jobman('serial', jobfile, '', inputs{:});    
        end
        disp('===========FINISH STEP 1: Coregister PET to MRI ===========');
        waitbar(1/4,hwait2,sprintf('Done %d / %d steps, Current: %s',1,4, 'Segementation of MRI'));
    catch
        scr_write_log(log_file, [sname, ' : [FAIL] at ', 'Step 1: Coreg'], 'a', '%s \n');
        close(hwait2);
        continue;
    end

    %% ==================STEP 2: segment MRI==================
    try
        jobfile = {fullfile(job_dir_path, 'step2_job.m')};
        inputs = cell(1, 1);
        inputs{1, 1} = {fullfile(cur_path, [mri tail])};
        spm('defaults', 'FMRI');
        spm_jobman('serial', jobfile, '', inputs{:});
        disp('===========FINISH STEP 2: Segment MRI ===========');
        waitbar(2/4,hwait2,sprintf('Done %d / %d steps, Current: %s',2,4, 'Matching'));
    catch
        scr_write_log(log_file, [sname, ' : [FAIL] at ', 'Step 2: Segmentation'], 'a', '%s \n');
        close(hwait2);
        continue;
    end

        %% ==================STEP 3: matching==================
    try
        saved_prefix = 'm_'; % wm_ext_, i_wm_ext
        is_inverse = 1;
        mask_prefix = 'c2'; % c1: gm, c2: wm
        pet_file = fullfile(cur_path, ['r' pet tail]);
        mask_file = fullfile(cur_path, [ mask_prefix mri tail]);
        scr_masking_pet(pet_file, mask_file, THRESHOLD, is_inverse, saved_prefix);
        disp('===========FINISH STEP 3===========');
        waitbar(3/4,hwait2,sprintf('Done %d / %d steps, Current: %s',3,4, 'Transform ROI_MNI template to MRI space'));
    catch
        scr_write_log(log_file, [sname, ' : [FAIL] at ', 'Step 3: Matching'], 'a', '%s \n');
        close(hwait2);
        continue;
    end

    %% ==================STEP 4: ROI_MNI -> MRI ==================
    try
        if approach == 2 % OLD: coregister ROI_MNI -> MRI
            jobfile = {fullfile(job_dir_path, 'step3_job.m')};
            inputs = cell(2, 1);
            inputs{1, 1} = {fullfile(cur_path, [mri tail])};
            inputs{2, 1} = {fullfile(cur_path, ['r' [sname 'ROI_MNI_V4.nii'] tail])};
            spm('defaults', 'FMRI');
            spm_jobman('serial', jobfile, '', inputs{:});
            disp('===========Done STEP 4: Coregister AAL template to MRI ===========');

        else % NEW: Inversely normalized ROI_MNI -> MRI
            jobfile = {fullfile(job_dir_path, 'inv_norm_job.m')};
            inputs = cell(2, 1);
            new_tpl_name = fullfile(cur_path, [sname, 'ROI_MNI_V4.nii']);
            copyfile(fullfile(job_dir_path, 'ROI_MNI_V4.nii') , new_tpl_name);
            inputs{1, 1} = {fullfile(cur_path, [mri(1:end-4) '_seg_inv_sn.mat'])}; % mat name
            inputs{2, 1} = {[new_tpl_name tail]};
            spm('defaults', 'FMRI');
            spm_jobman('serial', jobfile, '', inputs{:});
            disp('===========Done STEP 4: Inverse Normalization ===========');
        end
        waitbar(4/4,hwait2,sprintf('Done %d / %d steps',4,4));
    catch
        scr_write_log(log_file, [sname, ' : [FAIL] at ', 'Step 4: Transform ROI_MNI_V4'], 'a', '%s \n');
        close(hwait2);
        continue;
    end
    
    scr_write_log(log_file, [sname, ' : [SUCCESS]'], 'a', '%s \n');
    close(hwait2);
end
close(hwait);