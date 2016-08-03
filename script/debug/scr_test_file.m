load ROI_MNI_V4_List.mat;
load ROI_MNI_V4_Border.mat;

% const
LOWER_BOUND_REF_ID = 9001;
UPPER_BOUND_REF_ID = 9082;

SAVED_RELATIVE = false;

% 1. -----------Load file pure Grey matter PET-----------------------------
%[FileName,PathName] = uigetfile({'*.hdr'; '*.mat'; '*.img'} ,'Load the Functional Image (prefix: m_r*.ini)!');


%name1 = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\fixerrors\script\debug\m_rJI_BYEONG_O_20151125_17204_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain+SUM.hdr';
name1 = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\fixerrors\script\debug\m_rJI_BYEONG_O_20151125_17204_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain+SUM.img,1';


% load_nii
% try
%     hdr = load_nii(name1); %([PathName FileName]);
% catch
%     hdr = load_untouch_nii(name1); %([PathName FileName]);
% end
% oimg = double(hdr.img);


% load spm
hdr = spm_vol(deblank(name1));
oimg = spm_read_vols(hdr);

% Voxel size
% VOX_UNIT = hdr.hdr.dime.pixdim(2:4);
% VOX_UNIT = prod(VOX_UNIT);

VOX_UNIT = 2.1;


% load interested ROIs from file config 'scr_selected_VOI.m'
[roi_map, roi_names] = scr_selected_VOI();

% 2. -----------Load MNI template label file-------------------------------
%[FileName2,PathName2] = uigetfile({'*.hdr'; '*.mat'; '*.img'} ,'Load template AAL( rROI_MNI_V4.nii )!');


% name2 = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\fixerrors\script\debug\rrJI_BYEONG_OROI_MNI_V4.nii';
name2 = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\fixerrors\script\debug\rrJI_BYEONG_OROI_MNI_V4.nii,1';

% try
%     hdrTpl = load_nii(name2); %([PathName2 FileName2]);
% catch
%     hdrTpl = load_untouch_nii(name2); %([PathName2 FileName2]);
% end
% oimgTpl = hdrTpl.img;

hdrTpl = spm_vol(deblank(name2));
oimgTpl = spm_read_vols(hdrTpl);


% 3. -----------Select ROI definition file---------------------------------
spec_roi_id= scr_select_roi_def_file();


% 4. -----------Calculate SUV----------------------------------------------
% parameter for calculation SUV
prompt = {'Subject weight (kg)', 'Dosage (Mbq)', 'time (minutes)', 'half_life (seconds)', 'suv threshold'};
dlg_title = 'Specify SUV parameter values';
num_lines = 1;
def = {'61.8','321.9','90','6500','0.7'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% assign values
weight = str2double(answer{1});
dose = str2double(answer{2});
time = str2double(answer{3});
half_life = str2double(answer{4});
suv_thresh = str2double(answer{5});

% suv is variable stored infomation of ROIs, max SUV, mean SUV
suv = struct();

% multiplier for SUV
decay_factor  = exp(-log2(time*60/half_life));
multiplier = weight*decay_factor/(1000*dose);

% 4.a) Calculate SUV of reference VOI (cerebellar cortex) -----------------
% name: from CERCRU1G to CER10D
% id: from 9021 to 9082
% find voxels belong to ROI in template
maskTpl = zeros(size(oimgTpl));
tempIdx = find(oimgTpl>= 9021 & oimgTpl <= 9082);
maskTpl(tempIdx) = 1;

% masked image by ROI
maskedImg = oimg .* maskTpl;
nonZerosVox = maskedImg(find(maskedImg));
nonZerosVox = nonZerosVox(:);

% TEST min, max, create THRESHOLD
nonZeroImg = (oimg(oimg > 0));
minInt = min(nonZeroImg(:));
maxInt = max(oimg(:));
threshVal = suv_thresh * (maxInt - minInt);

% calculate SUV
SUV_ref_max = max(nonZerosVox)*multiplier;
SUV_ref_mean = mean(nonZerosVox)*multiplier;
			
if isnan(SUV_ref_mean)
	SUV_ref_mean = 0.0001; % avoid deviding to zero
end

% 5. ------------ Save SUV map img-----------------------------------------
fnms1 = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\fixerrors\script\debug\m_rJI_BYEONG_O_20151125_17204_600_PTCT_FLORBETABEN_DYNAMIC_3D_Brain+SUM.img,1';
hdr1 = spm_vol(deblank(fnms1));
oimgHack = spm_read_vols(hdr1);
[pth,nam,ext] = fileparts(hdr1.fname);
hdr1.fname  = fullfile(pth,['suv' nam ext]);
hdr1 = spm_create_vol(hdr1); %save header to disk
oimgSave = oimgHack;
oimgSave(oimgSave < threshVal) = 0;
spm_write_vol(hdr1,oimgSave); %save image to disk

% 6.------------- Save SUV with specified ROI------------------------------
% if SAVED_RELATIVE
%     scr_save_relative_thresh;
% else
%     scr_save_absolutely_thresh;
% end


% 7. ------------ Calculation SUVR of each region VOI ---------------------
for i=1:length(roi_names)
	roi_name = roi_names(i);
    found = false;
	for j=1:length(ROI)
		if strcmp(roi_name, ROI(j).Nom_C)
			suv(i).index = j;
            found = true;
			break;
		end
	end
	
	if found
		suv(i).full_name = ROI(suv(i).index).Nom_L;	
		roi_ID = ROI(suv(i).index).ID;
		suv(i).ID = roi_ID;
	else
		suv(i).full_name = roi_name;
		suv(i).ID = -1;
		suv(i).index = -1;
		roi_ID = roi_map(roi_name{1,1});
	end
	
	% calculate SUV
	[SUV_max, SUV_mean, nonZerosVox, maskedImg] = scr_func_cal_suv(oimg, oimgTpl, roi_ID, multiplier);
    maskedImgFind = find(maskedImg);
    
    % calculate volume
    larger_thresh =  maskedImg >= threshVal;
				
	if isnan(SUV_mean)
		SUV_mean = 0;
	end
	
	% stored value
	suv(i).SUV_max = SUV_max;
	suv(i).SUV_mean = SUV_mean;
	suv(i).SUVR_max = SUV_max/SUV_ref_max; % SUVR
	suv(i).SUVR_mean = SUV_mean/SUV_ref_mean; % SUVR
	suv(i).intensity = nonZerosVox;
    suv(i).volumn = sum(larger_thresh(:)) * VOX_UNIT;
	
	[x,y,z] = ind2sub(size(oimg), maskedImgFind);
	suv(i).coord = [x y z]';
end