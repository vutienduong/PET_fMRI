list_file = '';
load(list_file);
for crun = 1:length(list_file)
    if exist(fullfile(cur_path, ['m_r' list_file(crun).pet]), 'file') == 2
        keep_idx = [keep_idx crun];
        disp(['Pet file of subject ' list_file(crun).name ' exist for analysis']);
    end
end
list_file = list_file(keep_idx);

nrun = length(list_file);
if nrun == 0 % no pet files of selected subjects exist in specified folder
    disp('[ERROR] NO ANY PET IMAGES OF SELECTED SUBJECTS FOUND, STOP PROGRAM !');
    return; 
end

guiParams.savedSuv = [guiParams.savedSuv num2str(guiParams.suvrThreshold)];
% write to Excel
try
    scr_write_to_Excel(guiParams.savedSuv, list_file);
    scr_write_to_ExcelSUV(guiParams.savedSuv, list_file);
catch
    warning('PROBLEM WITH XLSWRITE. DONT WORRY, TRY TO RUN SEVERAL TIMES ! ! !');
end