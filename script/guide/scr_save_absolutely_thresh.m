for threshVal = [1.5 1.6 1.7 1.8 1.9 2]
    % a. Intersect all specified ROIs
    maskTpl = zeros(size(oimgTpl));
    for i =1:length(spec_roi_id)
        tempIdx = find(oimgTpl == spec_roi_id(i));
        maskTpl(tempIdx) = 1;
    end
    maskedImg = (oimg*multiplier).* maskTpl;
    maskedImg(maskedImg < threshVal) = 0;

    % TODO: just option path, to easy to see
    maskedBgrImg = zeros(size(oimg));
    % maskedBgrImg(oimg > 0)= 1000;
    maskedImg = maskedImg + maskedBgrImg;

    % b. Save to spec_suv.nii file
    hdr.img = maskedImg;
    [pth,nam,ext] = fileparts(hdr.fileprefix);
    spec_roi_file = fullfile(pth, 'saved', ['spec_suv_', num2str(threshVal) , '.nii']);
    save_nii(hdr, spec_roi_file);
end