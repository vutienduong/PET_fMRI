function suv = scr_func2(GM_PET_img, rTpl_img, ROI, params, varargin)
% const
LOWER_BOUND_REF_ID = 9021;
UPPER_BOUND_REF_ID = 9082;

if length(varargin) > 0
    suvParams = varargin{1};
end

% LOAD interested ROIs
roi_map = suvParams.roiList;

% CREATE suv: variable stored infomation of ROIs, max SUV, mean SUV
suv = struct();

% LOAD m_r_PET file
if ~exist(GM_PET_img(1:(end-2)), 'file')
    disp(['[Inorge] ', params.name ]);
    return;
end

hdr = spm_vol(deblank(GM_PET_img));
VOX_UNIT = scr_func_cal_vox_size(hdr);
oimg = spm_read_vols(hdr);

% LOAD ROI_MNI template file
hdrTpl = spm_vol(deblank(rTpl_img));
oimgTpl = spm_read_vols(hdrTpl);

% [REMOVED] CREATE voxel size 
% gmPetImg2 = GM_PET_img(1:(end-2));
% try
%     temp = load_nii(gmPetImg2); %([PathName FileName]);
% catch
%     temp = load_untouch_nii(gmPetImg2); %([PathName FileName]);
% end
% 
% VOX_UNIT = temp.hdr.dime.pixdim(2:4);
% VOX_UNIT = prod(VOX_UNIT);
% clear temp gmPetImg2;



% CREATE multiplier for SUV
% -- appr 1
% decay_factor  = exp(-log2(params.time*60/params.half_life));
% decay_factor  = exp(-log(2)*(params.time*60/params.half_life));
% multiplier = params.weight*decay_factor/(params.dosage*1000);

% -- appr 2
decay_factor  = 2^(-params.time*60/params.half_life);
multiplier = params.weight/(decay_factor*params.dosage*1000);

% calculate SUV of reference VOI (cerebellar cortex) -------------------
% name: from CERCRU1G to CER10D
% id: from 9021 to 9082
[SUV_ref_max, SUV_ref_mean] = scr_func_cal_suv(oimg, oimgTpl, [LOWER_BOUND_REF_ID, UPPER_BOUND_REF_ID], multiplier);




% ============== Start SAVE suv file ======================================
% templates
SUV_FILE            = struct('img',oimg * multiplier,...
                             'name','_suv_',...
                             'thresh',0 );
              
SUV_SIG_FILE        = struct('img',oimg * multiplier,...
                             'name','_suvSig_',...
                             'thresh',0 );
              
SUVR_SIG_MEAN_FILE  = struct('img',oimg*(multiplier/SUV_ref_mean),...
                             'name','_suvrMeanSig_',...
                             'thresh', 0);

% TODO: check whether SUVR_SIG_MAX_FILE is required
% SUVR_SIG_MAX_FILE = struct('img',oimg* (multiplier/SUV_ref_max) , '_suvrMaxSig.img', 'thresh', 0);

% include all saved files
allSavedFiles = cell(0);
allRoiSavedFiles = cell(0);
countFiles = 0;

% initial save SUV_FILE (suvThresh = 0);
if suvParams.isSaveSuvMap % check whether SAVE SUV MAP
    countFiles = countFiles + 1;
    allSavedFiles{countFiles,1} = SUV_FILE;

    temp = SUV_FILE;
    temp.img = zeros(size(oimg));
    allRoiSavedFiles{countFiles,1} = temp;
end


% initial save SUV_SIG_FILE (s)
if suvParams.isSaveSuvThr % check whether SAVE SUV THRESH
    for i=1:length(suvParams.suvThreshold)
        newSuvSigFile = SUV_SIG_FILE;
        newSuvSigFile.thresh = suvParams.suvThreshold(i);
        countFiles = countFiles + 1;
        allSavedFiles{countFiles, 1} = newSuvSigFile;

        newSuvSigFile.img = zeros(size(oimg));
        allRoiSavedFiles{countFiles,1} = newSuvSigFile;
    end
end

% initial save SUVR_SIG_FILE (s)
if suvParams.isSaveSuvrThr % check whether SAVE SUV THRESH
    for i=1:length(suvParams.suvrThreshold)
        newSuvSigFile = SUVR_SIG_MEAN_FILE;
        newSuvSigFile.thresh = suvParams.suvrThreshold(i);
        countFiles = countFiles + 1;
        allSavedFiles{countFiles, 1} = newSuvSigFile;

        newSuvSigFile.img = zeros(size(oimg));
        allRoiSavedFiles{countFiles,1} = newSuvSigFile;
    end
end

% only save files for whole brain
for i=1 : countFiles
    temp = allSavedFiles{i, 1};
    hdr2 = hdr;
    hdr2.fname  = fullfile( suvParams.savedSuv,[suvParams.subName temp.name num2str(temp.thresh) '.img']);
    hdr2 = spm_create_vol(hdr2);
    temp.img(temp.img < temp.thresh) = 0;
    spm_write_vol(hdr2, temp.img);
end
% ============== End SAVE suv file ========================================


clear {SUV_FILE,SUV_SIG_FILE,SUVR_SIG_MEAN_FILE};

% calculation SUV of each region VOI -----------------------------------
roi_ids = keys(roi_map);
for i=1:length(roi_ids)
	found = false;
	roi_ID = roi_ids{i};
	for j=1:length(ROI)
		if roi_ID == ROI(j).ID
			suv(i).index = j;
			found = true;
			break;
		end
	end
	
	if found
		suv(i).full_name = ROI(suv(i).index).Nom_L;	
		suv(i).ID = roi_ID;
	else
		suv(i).full_name = values(roi_map,{roi_ID});
		suv(i).ID = -1;
		suv(i).index = -1;
	end

	% calculate SUV
	[SUV_max, SUV_mean, nonZerosVox, maskedImg] = scr_func_cal_suv(oimg, oimgTpl, roi_ID, multiplier);
	maskedImgFind = find(maskedImg);
	
	% stored value
	suv(i).SUV_max = SUV_max;
	suv(i).SUV_mean = SUV_mean;
	suv(i).SUVR_max = SUV_max/SUV_ref_max; % SUVR
	suv(i).SUVR_mean = SUV_mean/SUV_ref_mean; % SUVR
	
    
    % volume
    volume = struct();
    volume.original = length(maskedImgFind) * VOX_UNIT;
    volume.largerSuvThresh = sum(nonZerosVox > suvParams.suvThreshold(1) / multiplier) * VOX_UNIT;
    volume.largerSuvrThresh = sum(nonZerosVox > suvParams.suvrThreshold(1)  * SUV_ref_mean / multiplier) * VOX_UNIT;
    
    volume.intensity = nonZerosVox;
    [x,y,z] = ind2sub(size(oimg), maskedImgFind);
	volume.coord = [x y z]';
    suv(i).otherInfo = volume;
    
    % update suv, suvr along to ROI to allRoiSavedFiles
    for j=1:length(allRoiSavedFiles)
        temp = allRoiSavedFiles{j, 1};
        tempMask = maskedImg;
        tempMask( tempMask < temp.thresh) = 0;
        temp.img = temp.img + tempMask;
        allRoiSavedFiles{j, 1} = temp;
    end
        
end

% save Suv temp
eval(sprintf('SUV_%s = suv;', suvParams.subName));
save( fullfile( suvParams.savedSuv,['SUV_' suvParams.subName '.mat']) ,['SUV_' suvParams.subName]);

% Save for selected ROIs along to 
for i=1 : length(allRoiSavedFiles)
    temp =  allRoiSavedFiles{i, 1};
    hdr2 = hdr;
    hdr2.fname  = fullfile( suvParams.savedSuv,[suvParams.subName temp.name num2str(temp.thresh) '_ROI.img']);
    hdr2 = spm_create_vol(hdr2);
    spm_write_vol(hdr2,temp.img);
end