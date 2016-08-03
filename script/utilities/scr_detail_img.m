function detail_var = scr_detail_img()
fnms1 = spm_select(1,'image','Select image you want to see details (.nii or .img)');

%read WM of MRI
hdr1 = spm_vol(deblank(fnms1));
oimg = spm_read_vols(hdr1);

detail_var.max_inten = max(oimg(:));
detail_var.min_inten = min(oimg(:));
detail_var.dim = size(oimg);
detail_var.type = class(oimg);
detail_var.uni_val = length(unique(oimg));
detail_var.non_zero = length(find(oimg));
