% a = 0;
% if a == 0
%     a = 2;
%     if a == 1
%         break;
%     end
%     disp ('this is a =1');
% end
% 
% mat_file = 'list_file_all_56.mat';
% patt = '*.img';
% tail = ',1';
% job_dir_path = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles'; %TODO: hardcode
% cur_path = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects'; % TODO: hardcode, EDIT
% load(mat_file);
% cd(cur_path); %change current directory to cur_path
% nrun = length(list_file);
% 
% for crun = 1:nrun
% 	if exist(fullfile(cur_path, ['c1' list_file(crun).fmri]), 'file') ~= 2
% 	    disp(['Miss: ' list_file(crun).name]);
% 	end
% end

% test_file = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects\JO_YONG_HWAN_20170116_19282_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain(SUM).img,1';
wgm_ext = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\GM mask\thresh 0_7\wgm_ext\wgm_ext_rJO_YONG_HWAN_20170116_19282_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain(SUM).img,1';
wiwm_ext = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\WM extracted\thresh 0_7\wiwm_ext\wiwm_ext_rJO_YONG_HWAN_20170116_19282_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain(SUM).img,1';
non_ext = 'D:\RESEARCH\spm8\toolbox\aal\data and save\ALL METHODS USE NORMALIZATION\1 normal way based on default temp\WM non extracted\wrJO_YONG_HWAN_20170116_19282_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain(SUM).img,1';
img_file = wiwm_ext;

templ_file = 'D:\RESEARCH\spm8\toolbox\aal\necessaryFiles\Temp folder\wROI_MNI_V4.nii';
% test voxel size
% 1. scr_func_cal_vox_size
% hdr = spm_vol(deblank(test_file));
% VOX_UNIT1 = scr_func_cal_vox_size(hdr);

% 2. get_total
vols = spm_vol(img_file);
oimg = spm_read_vols(vols);
VOX_UNIT = abs(det(vols(1).mat));

% load template
hdrTpl = spm_vol(deblank(templ_file));
templ = spm_read_vols(hdrTpl);

% roi_map = load('62_roi.mat');
load('62_roi.mat');
roi_ids = keys(roi_map);
multiplier = 50; %hardcode
result = struct();

for i=1:length(roi_ids)
    roi_ID = roi_ids{i};
    % [SUV_max, SUV_mean, nonZerosVox, maskedImg] = scr_func_cal_suv(oimg, templ, roi_ID, multiplier);
    maskTpl = zeros(size(templ));
    tempIdx = find(templ == roi_ID);
	maskTpl(tempIdx) = 1;
    maskedImg = oimg .* maskTpl;
    
    maskedImgFind = find(maskedImg);
    volume = length(maskedImgFind) * VOX_UNIT / 1000;
    
    result(i).id = roi_ID;
    result(i).num_vol = length(maskedImgFind);
    result(i).vol = volume;
end
