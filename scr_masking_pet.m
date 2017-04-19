function scr_masking_pet(pet_file, mask_file, thresh, is_inverse, prefix)
% read pet
hdr1 = spm_vol(deblank(pet_file));
rpetimg = spm_read_vols(hdr1);

% read mask
hdr2 = spm_vol(deblank(mask_file));
wmgmimg = spm_read_vols(hdr2);

% binarization
timg = zeros(size(wmgmimg));
idx = wmgmimg > thresh;
timg(idx) = 1;
if is_inverse
    wmgmimg = not(timg); % inverse WM
else
    wmgimg = timg;
end

% multiple
oimg2 = rpetimg .* wmgmimg; 

%save image
[pth,nam,ext] = fileparts(hdr1.fname);
hdr1.fname  = fullfile(pth,[prefix nam ext]);
fprintf('%d voxels survive in %s\n',sum(oimg2(:)>0),hdr1.fname);
if exist(hdr1.fname, 'file') == 2
    fprintf('this file already exists, END');
else
    hdr1 = spm_create_vol(hdr1); %save header to disk
    spm_write_vol(hdr1,oimg2); %save image to disk
end
    