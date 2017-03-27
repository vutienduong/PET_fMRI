function opennii(nii)
N=nifti(nii);
if size(N.dat,4) == 1
   spm_image('Display',nii);
else
   if ~isdeployed, addpath(fullfile(spm('Dir'),'spm_orthviews')); end
   spm_ov_browser('ui',spm_select('expand',nii));
end