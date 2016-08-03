function scr_func1_thresh(fnms1, fnms2, threshold)
% BINARY WHITE MATTER IMAGE BY THRESHOLD, LARGER THAN THRESHOLD IS SET 1

%read WM of MRI
hdr1 = spm_vol(deblank(fnms1));
oimg = spm_read_vols(hdr1);
timg = zeros(size(oimg));
idx = oimg > threshold;
timg(idx) = 1;
oimg = not(timg); % inverse WM

% read PET
hdr2 = spm_vol(deblank(fnms2));
img = spm_read_vols(hdr2);

oimg2 = oimg .* img; % multiple       
	
if (sum(oimg2(:)>0) == 0)
    fprintf('Error: no voxels in any image survives threshold\n');
    return
end

%save image
[pth,nam,ext] = fileparts(hdr2.fname);
hdr2.fname  = fullfile(pth,['m_' nam ext]);
fprintf('%d voxels survive in %s\n',sum(oimg(:)>0),hdr2.fname);
% if exist(hdr2.fname, 'file') == 2
    % fprintf('this file already exists, END');
% else
    hdr2 = spm_create_vol(hdr2); %save header to disk
    spm_write_vol(hdr2,oimg2); %save image to disk
% end
    