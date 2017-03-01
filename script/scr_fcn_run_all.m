function [varargout] = scr_fcn_run_all(guiParams)
% Set directory inclusdes all processed files
mapStt = scr_get_Status();
cur_path = guiParams.cur_path;
patt = '*.img';
tail = ',1';

% Set directory of job files
job_dir_path = guiParams.job_dir_path;

if isfield(guiParams, 'aal_file') % step 1,2,3,4
    copyfile( guiParams.aal_file , fullfile(cur_path, 'ROI_MNI_V4.nii'));
end

% Mutable setting
if isfield(guiParams, 'binThresh') % step 1,2,3,4
    THRESHOLD = guiParams.binThresh;
else
    THRESHOLD = 0.3; 
end
STEPS = guiParams.steps; %[0 0 0 0 1];

CAL_AVG_SUVR = isfield(guiParams, 'runOpt3');

% ==================STEP 0: CREATE LIST OF FILE INFO =================
if ~isfield(guiParams, 'list_file') % step 1,2,3,4
    cd(guiParams.cur_path); %change current directory to cur_path
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
        list_file(j).status = mapStt(search_name);
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
    list_file_name = guiParams.list_file;
    load(list_file_name);
    list_file = list_file(guiParams.subList);
end

%load('list_file_2add.mat');
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
    t = readtable(guiParams.file_info,'Delimiter','\t','ReadVariableNames',true);
    params = table2struct(t);
    
    % guiParams.subList = 58:88;% HARD CODE, dung cho 40 image them vao sau nay
    % guiParams.subList = 60:62;
    
    params = params(guiParams.subList);
%     suvParams = struct();
%     suvParams.suvTh = guiParams.suvThreshold;
%     suvParams.suvrTh = guiParams.suvrThreshold;
%     suvParams.savedSuv = guiParams.savedSuv;
%     suvParams.roiList = guiParams.roiList;

    for crun = 1:nrun
        pet_img = list_file(crun).pet;
        pet_hdr = [pet_img(1:(end-3)) 'hdr'];
        GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ',1']);
        rTpl_img = fullfile(cur_path, ['rr' list_file(crun).name 'ROI_MNI_V4.nii,1']);
        disp(['...run subject ', list_file(crun).name]);
        guiParams.subName = list_file(crun).name;
        suvValue = scr_func2(GM_PET_img, rTpl_img, ROI, params(crun), guiParams);
        if isfield(suvValue, 'SUV_max')
            suv(crun).name = list_file(crun).name;
            suv(crun).value = suvValue;
        end
        disp('Done ...');
    end
end

%======ADDITION: calculate SUVR AVERAGE for POS, NEG subjs ======
if CAL_AVG_SUVR && exist('suv','var')
   suvall = scr_func_opt3_analyze( suv, list_file );
end

if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end