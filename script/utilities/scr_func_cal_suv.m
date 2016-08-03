function [SUV_max, SUV_mean, varargout] = scr_func_cal_suv(oimg, oimgTpl, boundaries, multiplier)
% find voxels belong to ROI in template
maskTpl = zeros(size(oimgTpl));
if length(boundaries) ==  1
	tempIdx = find(oimgTpl == boundaries);
	maskTpl(tempIdx) = 1;
else
	for i=1:(length(boundaries)/2)
		LOWER = boundaries(i*2-1);
		UPPER = boundaries(i*2);
		tempIdx = find(oimgTpl>= LOWER & oimgTpl <= UPPER);
		maskTpl(tempIdx) = 1;
	end	
end

% masked image by ROI
maskedImg = oimg .* maskTpl;
maskedImgFind = find(maskedImg);
nonZerosVox = maskedImg(maskedImgFind);
nonZerosVox = nonZerosVox(:);

% calculate SUV
SUV_max = max(nonZerosVox)*multiplier;
SUV_mean = mean(nonZerosVox)*multiplier;

if isnan(SUV_mean)
	SUV_mean = 0.0001; % avoid deviding to zero
end

if nargout > 2
	varargout{1} = nonZerosVox;
    varargout{2} = maskedImg;
end