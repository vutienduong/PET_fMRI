% Luu y la co 2 lua chon: Coreg PET to MRI hoac k co Coreg, truoc khi Norm PET to a [Manual PET template]

clear;

% define params and const
mat_file = 'list_file_all_31.mat'; %TODO: hardcode, EDIT
patt = '*.img';
tail = ',1';
job_dir_path = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles'; %TODO: hardcode
cur_path = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\2 based on manual temp\2 PET guild\WM non extracted\31 PETs'; % TODO: hardcode, EDIT
avg_temp_name = 'health_56_pet.img'; %TODO: hardcode, EDIT
avg_temp_folder = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles\Temp folder\pet temp'; %TODO: hardcode, EDIT

is_coreg_before_norm = 0;

% operate

load(mat_file);
cd(cur_path); %change current directory to cur_path
nrun = length(list_file);

if is_coreg_before_norm
    % ---- 1) COREGISTER ----
    cur_path = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects';
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

% ---- 2) NORMALIZATION ----
pet_prefix = '';
if is_coreg_before_norm
    pet_prefix = 'r';
end

jobfile = {fullfile(job_dir_path, 'norm_job_specify_temp.m')};
inputs = cell(3, nrun);
ind = 1;
temp_file = fullfile(avg_temp_folder, [avg_temp_name tail]);
for crun = 1:nrun
    inputs{1, crun} = {fullfile(cur_path, [pet_prefix list_file(crun).pet tail])};
    inputs{2, crun} = {fullfile(cur_path, [pet_prefix list_file(crun).pet tail])};
    inputs{3, crun} = {temp_file};
    % disp (['Existed: ' list_file(crun).name]);
end

jobs = repmat(jobfile, 1, nrun);
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
disp('===========Done STEP 2: Normalization ===========');