load ROI_MNI_V4_List.mat; % load cai nay se ra ROI
load ROI_MNI_V4_Border.mat;
aal_fold = 'D:\RESEARCH\spm8\toolbox\aal\demo\test Inverse Normalization';
aal_file = fullfile(aal_fold, 'wROI_MNI_V4.nii');

aal_file = 'D:\RESEARCH\spm8\toolbox\aal\demo\56 subjects\wROI_MNI_V4LEE_MYEONG_JA.nii';

hdr1 = spm_vol(deblank(aal_file));
aal_img = spm_read_vols(hdr1);
u_value = unique(aal_img);
u_value = u_value(2:end); % remove 0
roi_id = cell2mat({ROI.ID});
c = ismember(roi_id, u_value);
indexes = find(c);