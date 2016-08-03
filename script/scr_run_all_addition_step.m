% clear;

% Find all files which has extension path is .img
cur_path= spm_select(1,'dir','Select directory which involves PET image');
patt = '*.img';
tail = ',1';

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
STEPS = [0 0 0 0 1];
CAL_AVG_SUVR = true;

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
        search_name = temp(1:(underscore_index(4)-1));
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

% %==================STEP 1: coregister PET -> MRI==================
if STEPS(1)
    jobfile = {fullfile(job_dir_path, 'step1_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
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
    disp('===========FINISH STEP 1===========');
end

% %==================STEP 2: segment MRI==================
if STEPS(2)
    jobfile = {fullfile(job_dir_path, 'step2_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(1, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========FINISH STEP 2===========');
end

%==================STEP 3: matching==================
if STEPS(3)
    for crun = 1:nrun
        WM_img = fullfile(cur_path, ['c2' list_file(crun).fmri tail]);
        rPET_img = fullfile(cur_path, ['r' list_file(crun).pet tail]);
        scr_func1_thresh(WM_img, rPET_img, THRESHOLD);
    end
    disp('===========FINISH STEP 3===========');
end

% %==================STEP 3.1: coregister ROI_MNI -> MRI==================
if STEPS(4)
    jobfile = {fullfile(job_dir_path, 'step3_job.m')};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
        new_tpl_name = [list_file(crun).name 'ROI_MNI_V4.nii'];
        inputs{2, crun} = {fullfile(cur_path, ['r' new_tpl_name tail])};
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========FINISH STEP 3.1===========');
end

%==================STEP 4: calculate SUV, SUVR==================
if STEPS(5)
    load ROI_MNI_V4_List.mat;
    load ROI_MNI_V4_Border.mat;
    suv = struct();
    file_info= spm_select(1,'any','Select info file included Weight, Dosage, Time, Half life INFO.');
    t = readtable(file_info,'Delimiter','\t','ReadVariableNames',true);
    params = table2struct(t);

    for crun = 1:nrun
        pet_img = list_file(crun).pet;
        pet_hdr = [pet_img(1:(end-3)) 'hdr'];
        GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ',1']);
        rTpl_img = fullfile(cur_path, ['rr' list_file(crun).name 'ROI_MNI_V4.nii,1']);
        suv(crun).name = list_file(crun).name;
        disp(['...run subject ', list_file(crun).name]);
        suv(crun).value = scr_func2(GM_PET_img, rTpl_img, ROI, params(crun));
    end
end

%======ADDITION: calculate SUVR AVERAGE for POS, NEG subjs ======
if CAL_AVG_SUVR && exist('suv','var')
    i=1;
    while isempty(suv(i).value) && i < 17
        i=i+1;
    end

    % check index exceeded
    if i >= 17
        return;
    end

    % final var
    suvall = struct('index',{},'full_name',{},'ID',{},'NEG_max',{},'NEG_mean',{},...
    'POS_max',{},'POS_mean',{}, 'POS_max_Avg',{}, 'POS_max_Std',{}, 'POS_mean_Avg',{},...
    'POS_mean_Std',{},'NEG_max_Avg',{},'NEG_max_Std',{},'NEG_mean_Avg',{},...
    'NEG_mean_Std',{});
    [suvall(1:numel(suv(i).value)).index] =     deal(suv(i).value.index);
    [suvall(1:numel(suv(i).value)).full_name] = deal(suv(i).value.full_name);
    [suvall(1:numel(suv(i).value)).ID] =        deal(suv(i).value.ID);

    % temp vars
    POS_suv_mean = [];
    POS_suv_max = [];
    NEG_suv_mean = [];
    NEG_suv_max = [];

    % add data to temp vars
    num_rois = numel(suv(i).value);
    for crun = i : nrun
        if ~isempty(suv(crun).value)
            if list_file(crun).status == -1
                for j=1:num_rois
                    maxval = suv(crun).value(j).SUVR_max;
                    meanval = suv(crun).value(j).SUVR_mean;
                    if checkNotNullOrZero(maxval)
                        suvall(j).NEG_max(end+1) = maxval;
                    end
                    if checkNotNullOrZero(meanval)
                        suvall(j).NEG_mean(end+1) = meanval;
                    end
                end
            else
                for j=1:num_rois
                   maxval = suv(crun).value(j).SUVR_max;
                    meanval = suv(crun).value(j).SUVR_mean;
                    if checkNotNullOrZero(maxval)
                        suvall(j).POS_max(end+1) = maxval;
                    end

                    if checkNotNullOrZero(meanval)
                        suvall(j).POS_mean(end+1) = meanval;
                    end
                end
            end
        end
    end

    % calculate avg and std
    for j=1:num_rois
        suvall(j).POS_max_Avg = mean(suvall(j).POS_max);
        suvall(j).POS_max_Std = std(suvall(j).POS_max);
        suvall(j).POS_mean_Avg = mean(suvall(j).POS_mean);
        suvall(j).POS_mean_Std = std(suvall(j).POS_mean);

        suvall(j).NEG_max_Avg = mean(suvall(j).NEG_max);
        suvall(j).NEG_max_Std = std(suvall(j).NEG_max);
        suvall(j).NEG_mean_Avg = mean(suvall(j).NEG_mean);
        suvall(j).NEG_mean_Std = std(suvall(j).NEG_mean);
    end

    % remove redundant temporal fields
    fields = {'POS_max','POS_mean','NEG_max','NEG_mean'};
    suvall = rmfield(suvall,fields);

    % remove Std fields unless necessary
    fields = {'POS_max_Std','POS_mean_Std','NEG_max_Std','NEG_mean_Std'};
    suvall = rmfield(suvall,fields);
end