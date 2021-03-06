function [varargout] = scr_fcn_run_all_with_excel_cal_vol(guiParams)
% New method: 1. Coreg, 2. Segment, 3. Matching, 4. Inv Norm
% Old method: 1. Coreg (include ROI_MNI_V4), 2. Segment, 3. Matching, 4.
% Coreg

% Use 'necessaryFiles/tempListFile.mat' to load patient info (name, status, mri_name, pet_name, weight, dosage, time)

% Set directory inclusdes all processed files
cur_path = guiParams.cur_path;
suv = 1; % Fake
suvall = 1; % Fake
if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end


%% ==================STEP 5: calculate SUV, SUVR==================
% load list_file created in step I
try
    load(fullfile(scr_get_spm8_dir(), 'toolbox\pet_mri_tool\necessaryFiles\tempListFile.mat'));
catch
    warndlg('Please run step [Multi subject I] first.');
    return;
end

load ROI_MNI_V4_List.mat;
load ROI_MNI_V4_Border.mat;
suv = struct();

keep_idx = []; % use to keep index of "actually existed subjects" among selected subjects in folder
for crun = 1:length(list_file)
    if exist(fullfile(cur_path, ['m_r' list_file(crun).pet]), 'file') == 2
        keep_idx = [keep_idx crun];
        disp(['Extracted WM file of subject ' list_file(crun).name ' exist for analysis']);
    end
end

list_file = list_file(keep_idx);
nrun = length(list_file);
if nrun == 0 % no pet files of selected subjects exist in specified folder
    warndlg('No ''Extracted WM'' image of selected subjects found, STOP PROGRAM!');
    return; 
end

% saved_fold = guiParams.savedSuv;
% guiParams.savedSuv = [guiParams.savedSuv num2str(guiParams.suvrThreshold)];

guiParams.savedSuv = fullfile(guiParams.savedSuv, datestr(clock,'mmmm_dd_yyyy HH_MM'));
if exist(guiParams.savedSuv, 'dir') ~= 7
    mkdir(guiParams.savedSuv);
end
disp([ 'Run for SUVR thresh: ' num2str(guiParams.suvrThreshold)]);
disp([ 'Run for SUV thresh: ' num2str(guiParams.suvThreshold)]);

for crun = 1:nrun
    disp(['...run subject ', list_file(crun).name]);
    pet_img = list_file(crun).pet;
    pet_hdr = [pet_img(1:(end-3)) 'hdr'];
    
    if approach == 2 % old
        rTpl_img = fullfile(cur_path, ['rr' list_file(crun).name 'ROI_MNI_V4.nii,1']);
    else % new
        rTpl_img = fullfile(cur_path, ['w' list_file(crun).name 'ROI_MNI_V4.nii,1']);
    end
    
    GM_PET_img = fullfile(cur_path, ['m_r' pet_hdr ',1']);
    guiParams.subName = list_file(crun).name;
    suvValue = scr_func2(GM_PET_img, rTpl_img, ROI, list_file(crun), guiParams);
    if isstruct(suvValue) && isfield(suvValue, 'SUV_max')
        suv(crun).name = list_file(crun).name;
        suv(crun).status = list_file(crun).status;
        suv(crun).value = suvValue;
        writeFile = fullfile(guiParams.savedSuv, ['RESULT_' suv(crun).name '.csv']);
        writetable(struct2table(suv(crun).value), writeFile,'Delimiter',',');
    end
    disp(['DONE ... ', list_file(crun).name]);
    disp('__________________________________');
    disp(' ');
end
disp('[SUCCESS] FINISH STEP 5 CALCULATE SUV, SUVR ...');

%% save "suv, suvr" files
save(fullfile(guiParams.savedSuv, ['SUV_' datestr(clock,'mmmm_dd_yyyy HH_MM')]), 'suv');
save(fullfile(guiParams.savedSuv, ['SUVALL_' datestr(clock,'mmmm_dd_yyyy HH_MM')]), 'suvall');

%% 1. WRITE to .EXCEL file
% try
%     scr_write_to_Excel(guiParams.savedSuv, list_file);
%     scr_write_to_ExcelSUV(guiParams.savedSuv, list_file);
% catch
%     warndlg('PROBLEM WITH XLSWRITE. TRY TO RUN SEVERAL TIMES MORE !!!');
% end

%% 2. WRITE to .CSV file (multi subject in a file)
try
    multiSave = fullfile(guiParams.savedSuv, 'summary');
    mkdir(multiSave);
    scr_write_to_summary_csv(multiSave, suv);
    disp(['[SUCCESS] Write SUV, SUVR, VOL to CSV file. Check folder ''' multiSave ''' for result files.']);
    disp('==================================');
catch
    warndlg('Can''t write to CSV file.');
    return;
end

if nargout == 2
    varargout{1} = suv;
    varargout{2} = suvall;
end