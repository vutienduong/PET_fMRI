% a. Intersect all specified ROIs
maskTpl = zeros(size(oimgTpl));
for i =1:length(spec_roi_id)
    tempIdx = find(oimgTpl == spec_roi_id(i));
    maskTpl(tempIdx) = 1;
end
maskedImg = oimg .* maskTpl;
maskedImg(maskedImg < threshVal) = 0;

% TODO: just option path, to easy to see
maskedBgrImg = zeros(size(oimg));
maskedBgrImg(oimg > 0)= 1000;
maskedImg = maskedImg + maskedBgrImg;

% b. Save to spec_suv.nii file
hdr.img = maskedImg;
[pth,nam,ext] = fileparts(hdr.fileprefix);
spec_roi_file = fullfile(pth, 'spec_suv.nii');
save_nii(hdr, spec_roi_file);