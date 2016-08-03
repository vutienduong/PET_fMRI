% clear;

% tim tat ca cac file co duoi la .img
patt = '*.img';
tail = ',1';
cur_path = pwd;

list_file = struct(); % include fmri and pet fields in each element
list = dir(patt); % NOTE: current directory
nrun = length(list)/2;
j = 1;

% tao list file
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



%==================STEP 1: coregister PET -> MRI==================
jobfile = {fullfile(cur_path, 'step1_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    inputs{2, crun} = {fullfile(cur_path, [list_file(crun).pet tail])};
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

%==================STEP 2: segment MRI==================
jobfile = {fullfile(cur_path, 'step2_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

%==================STEP 3: matching==================
for crun = 1:nrun
    WM_img = fullfile(cur_path, ['c2' list_file(crun).fmri tail]);
    rPET_img = fullfile(cur_path, ['r' list_file(crun).pet tail]);
    scr_func1(WM_img, rPET_img);
end

%==================STEP 3.1: coregister ROI_MNI -> MRI==================
jobfile = {fullfile(cur_path, 'step3_1_job.m')};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = {fullfile(cur_path, [list_file(crun).fmri tail])};
    inputs{2, crun} = {fullfile(cur_path, ['ROI_MNI_V4.nii' tail])};
    inputs{3, crun} = [list_file(crun).name '_r'];
end
spm('defaults', 'FMRI');
spm_jobman('serial', jobs, '', inputs{:});

%==================STEP 4: calculate SUV, SUVR==================
load ROI_MNI_V4_List.mat;
load ROI_MNI_V4_Border.mat;
suv = struct();
for crun = 1:nrun
    pet_img = list_file(crun).pet;
    pet_hdr = [pet_img(1:(end-3)) 'hdr'];
    GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ]);
    rTpl_img = fullfile(cur_path, [list_file(crun).name '_rROI_MNI_V4.nii']);
    suv(crun).name = list_file(crun).name;
    suv(crun).value = scr_func2(GM_PET_img, rTpl_img, ROI);
end
