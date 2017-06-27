function [varargout] = scr_fcn_run_all(guiParams)
% New method: 1. Coreg, 2. Segment, 3. Matching, 4. Inv Norm
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
IS_SAVE_EXCEL = isfield(guiParams, 'isSaveExcel');

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
% if 0 % TODO: trick     
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
% if 0 % TODO for no sub
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
saved_prefix = 'm_'; % wm_ext_, i_wm_ext
if STEPS(3)
    is_inverse = 1;
    mask_prefix = 'c2'; % c1: gm, c2: wm
    for crun = 1:nrun
		pet_file = fullfile(cur_path, ['r' list_file(crun).pet tail]);
		% mask_file = fullfile(cur_path, ['c2' list_file(crun).fmri tail]);
        mask_file = fullfile(cur_path, [ mask_prefix list_file(crun).fmri tail]);
        scr_masking_pet(pet_file, mask_file, THRESHOLD, is_inverse, saved_prefix)
        % scr_func1_thresh(WM_img, rPET_img, THRESHOLD);
		
		% scr_func1_thresh_no_sub(rPET_img, rPET_img, THRESHOLD); % TODO for no sub
    end
    disp('===========FINISH STEP 3===========');
end

% %==================STEP 3.1 OLD: coregister ROI_MNI -> MRI==================
% if 0 % old, REMOVE
% % if STEPS(4) % TODO: for debug
%     jobfile = {fullfile(job_dir_path, 'step3_job.m')};
%     jobs = repmat(jobfile, 1, nrun);
%     inputs = cell(2, nrun);
%     for crun = 1:nrun
%         inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
%         new_tpl_name = [list_file(crun).name 'ROI_MNI_V4.nii'];
%         inputs{2, crun} = {fullfile(cur_path, ['r' new_tpl_name tail])};
%     end
%     spm('defaults', 'FMRI');
%     spm_jobman('serial', jobs, '', inputs{:});
%     disp('===========FINISH STEP 3.1===========');
% end

%==================STEP 4: Inversely normalized ROI_MNI -> MRI============
if STEPS(4)
    jobfile = {fullfile(job_dir_path, 'inv_norm_job.m')};
    inputs = cell(2, nrun);
    for crun = 1:nrun
        new_tpl_name = ['ROI_MNI_V4' list_file(crun).name '.nii'];
        copyfile(fullfile(job_dir_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
        inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri(1:end-4) '_seg_inv_sn.mat'])}; % mat name
        inputs{2, crun} = {fullfile(cur_path, [new_tpl_name tail])};
    end

    jobs = repmat(jobfile, 1, nrun);
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    disp('===========Done STEP 4: Inverse Normalization ===========');
end

%==================STEP 5: calculate SUV, SUVR==================
if STEPS(5) && ~IS_SAVE_EXCEL
    load ROI_MNI_V4_List.mat;
    load ROI_MNI_V4_Border.mat;
    suv = struct();
    t = readtable(guiParams.file_info,'Delimiter','\t','ReadVariableNames',true);
    params = table2struct(t);
    % guiParams.subList = 1:31;
    % guiParams.subList = 58:88;% HARD CODE, dung cho 40 image them vao sau nay
    % guiParams.subList = [25,35]; %TODO : for debug
    
    %list_name = {list_file(guiParams.subList).name};
    % list_name = {list_file.name};
    
%     list_file = list_file(guiParams.subList); % cut down list file to selected subjects
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
%     suvParams = struct();
%     suvParams.suvTh = guiParams.suvThreshold;
%     suvParams.suvrTh = guiParams.suvrThreshold;
%     suvParams.savedSuv = guiParams.savedSuv;
%     suvParams.roiList = guiParams.roiList;

old_savedSuv = guiParams.savedSuv;
tempSuvThr = 0.5;
%  for tempVar1 = [0.9, 1.55 , 2.0] %[0.9, 1.1, 1.3, 1.55 , 1.8, 2.0]% 0.9:0.1:2.0
%     guiParams.suvrThreshold = tempVar1;
%     guiParams.suvThreshold = tempSuvThr;
    
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

%======ADDITION: calculate SUVR AVERAGE for POS, NEG subjs ======
% if CAL_AVG_SUVR && exist('suv','var') && ~IS_SAVE_EXCEL
%    suvall = scr_func_opt3_analyze( suv, list_file );
% end

if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end