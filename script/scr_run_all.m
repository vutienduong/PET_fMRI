% clear;
% keySet = {'AN_YEONG_SUN', 'BAK_JEONG_SUN','CHO_KYEONG_JA','JEON_YEONG_TAE',...
%     'JI_BYEONG_O','KIM_BYEONG_HAG','KIM_JEOM_SUN','KIM_MYEONG_SEON',...
%     'KIM_MYEONG_WEON','KIM_SAM_SEOG','KIM_SEONG_HOO','KIM_YEONG_KIL',...
%     'KIM_YONG_KI','KO_JEOM_SUK','MA_IN_HWA','YUN_HYEONG_SIK','YUN_KI_JA'};
% valueSet = {-1,1,-1,1,1,1,1,-1,1,-1,-1,1,1,-1,-1,-1,1};
% mapStt = containers.Map(keySet,valueSet);
% 
% % tim tat ca cac file co duoi la .img
% patt = '*.img';
% tail = ',1';
cur_path = pwd;
% % 
% % % DEFAULT PARAMETER VALUES
DEFL_WEIGHT     =   60;
DEFL_DOSE       =   400;
DEFL_TIME       =   60;
DEFL_HALFLIFE   =   6500;
% 
% list_file = struct(); % include fmri and pet fields in each element
% list = dir(patt); % NOTE: current directory
% nrun = length(list)/2;
% j = 1;
% 
% % tao list file
% while ~isempty(list)
%     assign_pet = false;
% 	temp = list(1).name;
%     if strfind(temp, 'PTCT_FLORBETABEN')
%         list_file(j).pet = temp;
%         assign_pet = true;
%     else
%         list_file(j).fmri = temp;
%     end
% 	list(1) = []; % remove considering element
% 	underscore_index = strfind(temp, '_');
% 	search_name = temp(1:(underscore_index(3)-1));
%     list_file(j).name = search_name;
%     list_file(j).status = mapStt(search_name);
% 	for i=1:length(list)
% 		if ~isempty(strfind(search_name,'_'))
%             if assign_pet
%                 list_file(j).fmri = list(i).name;
%             else
%                 list_file(j).pet = list(i).name;
%             end
%             list(i) = [];
% 			break;
% 		end
% 	end
% 	j = j +1;
% end

%==================STEP 1: coregister PET -> MRI==================
% jobfile = {fullfile(cur_path, 'job', 'step1_job.m')};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(2, nrun);
% for crun = 1:nrun
    % inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    % inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
% end
% spm('defaults', 'FMRI');
% spm_jobman('serial', jobs, '', inputs{:});

% %==================STEP 2: segment MRI==================
% jobfile = {fullfile(cur_path, 'job', 'step2_job.m')};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(1, nrun);
% for crun = 1:nrun
    % inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
% end
% spm('defaults', 'FMRI');
% spm_jobman('serial', jobs, '', inputs{:});

% %==================STEP 3: matching==================
% for crun = 1:nrun
    % WM_img = fullfile(cur_path, ['c2' list_file(crun).fmri tail]);
    % rPET_img = fullfile(cur_path, ['r' list_file(crun).pet tail]);
    % scr_func1(WM_img, rPET_img);
% end

% %==================STEP 3.1: coregister ROI_MNI -> MRI==================
% jobfile = {fullfile(cur_path, 'job', 'step1_job.m')};
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(2, nrun);
% for crun = 1:nrun
    % inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    % new_tpl_name = [list_file(crun).name 'ROI_MNI_V4.nii'];
    % copyfile(fullfile(cur_path, 'ROI_MNI_V4.nii') , fullfile(cur_path, new_tpl_name));
    % inputs{2, crun} = {fullfile(cur_path, [new_tpl_name tail])};
    % % inputs{3, crun} = [list_file(crun).name 'r'];
% end
% spm('defaults', 'FMRI');
% spm_jobman('serial', jobs, '', inputs{:});

% % delete unecesssary ROI_MNI files
% for crun = 1:nrun
    % delete(fullfile(cur_path, [list_file(crun).name 'ROI_MNI_V4.nii']));
% end

%==================STEP 4: calculate SUV, SUVR==================
load ROI_MNI_V4_List.mat;
load ROI_MNI_V4_Border.mat;
% suv = struct();
% params = struct();
% 
% % parameter for calculation SUV
% % prompt = {'Subject weight (kg)', 'Dosage (Mbq)', 'time (minutes)', 'half_life (seconds)'};
% % dlg_title = 'Specify SUV parameter values';
% % num_lines = 1;
% % def = {'60','400','60','6500'};
% % answer = inputdlg(prompt,dlg_title,num_lines,def);
% 
% % assign values
% % TODO: default
% params.weight       =   DEFL_WEIGHT; 
% params.dose         =   DEFL_DOSE; 
% params.time         =   DEFL_TIME; 
% params.half_life    =   DEFL_HALFLIFE;
% 
% for crun = 1:nrun
%     pet_img = list_file(crun).pet;
%     pet_hdr = [pet_img(1:(end-3)) 'hdr'];
%     GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ]);
%     rTpl_img = fullfile(cur_path, ['r' list_file(crun).name 'ROI_MNI_V4.nii']);
%     suv(crun).name = list_file(crun).name;
%     suv(crun).value = scr_func2(GM_PET_img, rTpl_img, ROI, params);
% 
% end

% SUMMARY SUVR
% find first not null element suv
% suv = suvTemp;
nrun = length(suv);
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
