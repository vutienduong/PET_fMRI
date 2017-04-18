% script for creating list_file
% default that we are in PET, MRI folder

patt = '*.img';
tail = ',1';

job_dir_path = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles'; %TODO: hardcode

% cur_path = 'D:\RESEARCH\spm8\toolbox\aal\data and save\header files changed to PET Eng name'; % TODO: hardcode
cur_path = 'D:\RESEARCH\spm8\toolbox\aal\data and save\test_norm'; % TODO: hardcode, test
cd(cur_path); %change current directory to cur_path

is_debug = 1;
if ~is_debug
    list_file = struct(); % include fmri and pet fields in each element
    list = dir(patt); % NOTE: current directory
    j = 1;
    while ~isempty(list)
        assign_pet = false;
        temp = list(1).name;
        if strfind(temp, 'PTCT_FLORBETABEN') % check this is PET or MRI
            list_file(j).pet = temp;
            assign_pet = true;
        else
            list_file(j).fmri = temp;
        end

        list(1) = []; % remove considering element
        underscore_index = strfind(temp, '_');
        search_name = temp(1:(underscore_index(3)-1));
        list_file(j).name = search_name;
        % list_file(j).status = mapStt(search_name); %TODO: add status later
        % (positive, negative)
        for i=1:length(list)
            if ~isempty(strfind(search_name,'_'))

                if assign_pet % check this is PET or MRI
                    list_file(j).fmri = list(i).name;
                else
                    list_file(j).pet = list(i).name;
                end
                list(i) = [];
                break;
            end
        end
        j = j +1;
    end
else
    load('D:\RESEARCH\spm8\toolbox\aal\data and save\test_norm\list_file_test_norm_2_sub.mat'); %TODO: harcode
end

nrun = length(list_file);

% ----- COREGISTER & NORMALIZATION -----
if ~is_debug
    % ---- 1) COREGISTER ----
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
        inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 1: Coregister ===========');

    % ---- 2) NORMALIZATION ----
    jobfile = {fullfile(job_dir_path, 'norm_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(1, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
        inputs{2, crun} = {fullfile(cur_path, [list_file(crun).fmri tail]) ...
            fullfile(cur_path, ['r' list_file(crun).pet tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 1: Normalization ===========');
end


% ----- CALCULATE AVERAGE OF IMAGES -----
is_by_hand = 1;
if is_by_hand
    jobfile = {'D:\RESEARCH\spm8\toolbox\aal\data and save\test_norm\average_img2_job.m'};
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
    inputs{2, 1} = 'avg_wrpet_temp.img'; % Output name, TODO: hardcode
    inputs{3, 1} = {'D:\RESEARCH\spm8\toolbox\aal\data and save\test_norm\'}; % Output dir, TODO: hardcode
    inputs{4, 1} = expression_str; % Image Calculator: Expression - cfg_entry
    
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
end

