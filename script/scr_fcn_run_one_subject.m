function scr_fcn_run_one_subject(guiParams)
% save all created files to MRI folder (cur_path)
cur_path = guiParams.cur_path;
mri_img = guiParams.mri;
pet_img = guiParams.pet;
approach = guiParams.approach; % 1: new, 2: old

[mri_pathstr,mri_name,mri_ext] = fileparts(mri_img);
[pet_pathstr,pet_name,pet_ext] = fileparts(pet_img);

%% Save 'list_file' and 'approach' for step (Multi subjects II)
list_file = struct();
list_file.name = guiParams.subject_name;
list_file.mri = [mri_name '.img'];
list_file.pet = [pet_name '.img'];
if guiParams.status == 1
    list_file.status = 'positive';
else
    list_file.status = 'negative';
end
try
    list_file.weight = str2num(guiParams.file_info.weight);
    list_file.dosage = str2num(guiParams.file_info.dosage);
    list_file.time = str2num(guiParams.file_info.time);
    list_file.half_life = str2num(guiParams.file_info.half_life);
catch
    warndlg('Error! Please check weight, dosage, time, half_life values are valid numeric values!');
    return;
end
save(fullfile(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\tempListFile.mat'), 'list_file', 'approach');

%% RUN 4 step
tail = ',1';
job_dir_path = guiParams.job_dir_path;

% Mutable setting
if isfield(guiParams, 'binThresh') % step 1,2,3,4
    THRESHOLD = guiParams.binThresh;
else
    THRESHOLD = 0.3; 
end

if approach == 2
    new_tpl_name = fullfile(cur_path, [guiParams.subject_name 'ROI_MNI_V4.nii']);
    copyfile(guiParams.aal_file , new_tpl_name);
    jobfile = {fullfile(job_dir_path, 'step1_job.m')};
    inputs = cell(3, 1);
    inputs{1, 1} = {mri_img};
    inputs{2, 1} = {pet_img};
    inputs{3, 1} = {[new_tpl_name tail]};
else
    %==================STEP 1: coregister PET -> MRI==================
    jobfile = {fullfile(job_dir_path, 'step1_1_job.m')};
    inputs = cell(2, 1);
    inputs{1, 1} = {mri_img};
    inputs{2, 1} = {pet_img};
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobfile, '', inputs{:});
disp('===========FINISH STEP 1: Coregister PET to MRI ===========');
    
% %==================STEP 2: segment MRI==================
jobfile = {fullfile(job_dir_path, 'step2_job.m')};
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, 1);
inputs{1, 1} = {mri_img};
spm('defaults', 'FMRI');
spm_jobman('serial', jobfile, '', inputs{:});
disp('===========FINISH STEP 2: Segment MRI ===========');

%==================STEP 3: matching==================
saved_prefix = 'm_'; % wm_ext_, i_wm_ext
is_inverse = 1;
mask_prefix = 'c2'; % c1: gm, c2: wm
rpet_file = fullfile(cur_path, ['r' pet_name pet_ext]);
% mask_file = fullfile(cur_path, ['c2' list_file(crun).fmri tail]);
mask_file = fullfile(cur_path, [ mask_prefix mri_name mri_ext]);
scr_masking_pet(rpet_file, mask_file, THRESHOLD, is_inverse, saved_prefix)
disp('===========FINISH STEP 3: Matching ===========');


if approach == 2
    % ==================STEP 4 OLD: coregister ROI_MNI -> MRI==================
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    inputs = cell(2, 1);
    inputs{1, 1} = {mri_img};
    new_tpl_name = [guiParams.subject_name 'ROI_MNI_V4.nii'];
    source_file = fullfile(cur_path, ['r' new_tpl_name]); % rMNI_V4_
    
%     if exist(source_file, 'file') == 2
%         origin_dest_file = fullfile(cur_path, ['origin_' new_tpl_name]); % origin_MNI_V4
%         dest_file = fullfile(cur_path, new_tpl_name); % MNI_V4
%         movefile(dest_file, origin_dest_file, 'f'); % rename ROI_MNI_ ... to origin_ROI_MNI_...
%         movefile(source_file, dest_file, 'f'); % rename rROI_MNI_ ... to ROI_MNI_...
%     end
    
    inputs{2, 1} = {source_file};
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobfile, '', inputs{:});
    disp('===========Done STEP 4: Coregister AAL template to MRI ===========');
else
    %==================STEP 4: Inversely normalized ROI_MNI -> MRI============
    jobfile = {fullfile(job_dir_path, 'inv_norm_job.m')};
    inputs = cell(2, 1);
    new_tpl_name = [guiParams.subject_name 'ROI_MNI_V4.nii'];
    copyfile(fullfile(job_dir_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
    inputs{1, 1} = {fullfile(cur_path, [mri_name '_seg_inv_sn.mat'])}; % mat name
    inputs{2, 1} = {fullfile(cur_path, [new_tpl_name tail])};

    spm('defaults', 'FMRI');
    spm_jobman('serial', jobfile, '', inputs{:});
    disp('===========Done STEP 4: Inverse Normalization ===========');
end