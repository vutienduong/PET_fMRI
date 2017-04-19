% define params and const
mat_file = 'list_file_49_correct_segment.mat'; %TODO: hardcode, EDIT
patt = '*.img';
tail = ',1';
job_dir_path = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles'; %TODO: hardcode
cur_path = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects'; % TODO: hardcode, EDIT


templ_name = 'health_56_pet.img'; %TODO: hardcode, EDIT
templ_folder = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles\Temp folder\pet temp'; %TODO: hardcode, EDIT
 
% templ_file = fullfile(templ_folder, [templ_name tail]); % manual

templ_file = 'D:\RESEARCH\spm8\templates\T1.nii'; % default

% STEP flags
is_coreg = 0;
is_segment = 0;
is_extract = 0;
is_norm = 1;

% EXTRACT params
thresh = 0.7;
is_inverse = 1;
mask_prefix = 'c2'; % c1: gm, c2: wm
saved_prefix = 'iwm_ext_'; % wm_ext_, i_wm_ext

% operate
load(mat_file);
cd(cur_path); %change current directory to cur_path
nrun = length(list_file);

% ---- 1) COREGISTER ----
if is_coreg
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
        inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
    end
    jobs = repmat(jobfile, 1, nrun);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 1: Coregister ===========');
end

% ---- 2) SEGMENTATION ----
if is_segment
    jobfile = {fullfile(job_dir_path, 'step2_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(1, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 2: Segment ===========');
end

% ---- 3) EXTRACT ----
if is_extract  
    for crun = 1:nrun
        pet_file = fullfile(cur_path, ['r' list_file(crun).pet tail]);
        mask_file = fullfile(cur_path, [ mask_prefix list_file(crun).fmri tail]);
        scr_masking_pet(pet_file, mask_file, thresh, is_inverse, saved_prefix)
    end
    disp('===========Done STEP 3: Extract ===========');
end

% ---- 4) NORMALIZATION ----
if is_norm
    pet_prefix = 'r';
    jobfile = {fullfile(job_dir_path, 'norm_job_specify_temp.m')};
    inputs = cell(3, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
        inputs{2, crun} = {fullfile(cur_path, [saved_prefix pet_prefix list_file(crun).pet tail])};
        inputs{3, crun} = {templ_file};
    end

    jobs = repmat(jobfile, 1, nrun);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 4: Normalization ===========');
end