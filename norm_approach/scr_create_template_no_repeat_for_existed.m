clear;
load('list_file_all_56_same_mri.mat');

patt = '*.img';
tail = ',1';
job_dir_path = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles'; %TODO: hardcode
cur_path = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects'; % TODO: hardcode, test
cd(cur_path); %change current directory to cur_path

avg_temp_name = 'all_56(same_mri)_pet.img';
avg_temp_folder = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\2 based on manual temp\Temp folder';
nrun = length(list_file);


is_cog_and_norm = 0;
if is_cog_and_norm
    % ---- 1) COREGISTER ----
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    inputs = cell(2, 0);
    ind = 1;
    for crun = 1:nrun
        if exist(fullfile(cur_path, ['r' list_file(crun).pet]), 'file') ~= 2
            inputs{1, ind} = {fullfile(cur_path, [list_file(crun).fmri tail])};
            inputs{2, ind} = {fullfile(cur_path, [list_file(crun).pet tail])};
            ind = ind + 1;
        end
    end

    jobs = repmat(jobfile, 1, ind-1);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 1: Coregister ===========');

    % ---- 2) NORMALIZATION ----
    jobfile = {fullfile(job_dir_path, 'norm_job.m')};
    inputs = cell(2, 0);
    ind = 1;
    for crun = 1:nrun
        if exist(fullfile(cur_path, ['wr' list_file(crun).pet]), 'file') ~= 2
            inputs{1, ind} = {fullfile(cur_path, [list_file(crun).fmri tail])};
            inputs{2, ind} = {fullfile(cur_path, [list_file(crun).fmri tail]) ...
                fullfile(cur_path, ['r' list_file(crun).pet tail])};
            ind = ind + 1;
        end
    end

    jobs = repmat(jobfile, 1, ind-1);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 2: Normalization ===========');
end

% ----- 3) CALCULATE AVERAGE ----
jobfile = {'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles\average_img_job.m'};
jobs = repmat(jobfile, 1, 1);
inputs = cell(4, 1);

% list wr_pet files
wrpet_files = cell(nrun, 1);
for crun =1:nrun
    wrpet_files{crun, 1} = fullfile(cur_path, ['wr' list_file(crun).pet tail]);
end

% string of expression
expression_str = '(';
for crun = 1:nrun
    expression_str = strcat(expression_str, ['i' num2str(crun) '+']);
end
len = length(expression_str);
expression_str = expression_str(1:len - 1); % remove redundant '+' character
expression_str = strcat(expression_str, [')/' num2str(nrun)]);

% assign parameter
inputs{1, 1} = wrpet_files; % Image Calculator: Input Images - cfg_files
inputs{2, 1} = avg_temp_name; % Output name
inputs{3, 1} = {avg_temp_folder}; % Output dir
inputs{4, 1} = expression_str; % Image Calculator: Expression - cfg_entry

spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});
disp('===========Done STEP 3: Average ===========');