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
is_extract = 1;
is_norm = 0;
is_inv_norm = 0;
is_cal_suv = 0;

% EXTRACT params
thresh = 0;
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

% ---- 4) NORMALIZATION ---- Not necessary
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

% ---- 5) INVERSE NORMALIZATION for ROI_MNI_V4 -----------
if is_inv_norm
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
    disp('===========Done STEP 5: Inverse Normalization ===========');
end

% ---- 6) CALCULATE SUV,SUVR, VOLUME --------------
if is_cal_suv
    m_rpet_prefix = 'm_r';
    load ROI_MNI_V4_List.mat; % load cai nay se ra ROI
    load ROI_MNI_V4_Border.mat;
    load scaninfo_72_sub.mat;
    load 62_roi.mat; % 62 default ROI
    
    LOWER_BOUND_REF_ID = 9021;
    UPPER_BOUND_REF_ID = 9082;
    
    suv = struct();
    
    for crun = 1:nrun
        disp(['...run subject ', list_file(crun).name]);
        
        % get file name, scaninfo
        pet_img = list_file(crun).pet;
        pet_hdr = [pet_img(1:(end-3)) 'hdr'];
        GM_PET_img = fullfile(cur_path, [m_rpet_prefix pet_hdr ',1']);
        rTpl_img = fullfile(cur_path, ['wROI_MNI_V4' list_file(crun).name '.nii,1']);
        scanInd = find(strcmp({params.name}, list_file(crun).name));
        scan_info = params(scanInd);
        
        % calculate VOX_UNIT
        % - cach 1
        vols = spm_vol(GM_PET_img);
        oimg = spm_read_vols(vols); 
        VOX_UNIT = abs(det(vols(1).mat));
        % - cach 2
        
        % calculate decay factor, multiplier
        decay_factor  = 2^(-scan_info.time*60/scan_info.half_life);     
        multiplier = scan_info.weight/(decay_factor*scan_info.dosage);

        % calculate SUVmax, SUVmean, Volume
        
        
        % guiParams.subName = list_file(crun).name;
        suvValue = scr_func2(GM_PET_img, rTpl_img, ROI, params(crun), guiParams);
        if isfield(suvValue, 'SUV_max')
            suv(crun).name = list_file(crun).name;
            suv(crun).value = suvValue;
        end
        disp('Done ...');
    end
end