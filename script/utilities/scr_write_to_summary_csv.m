function scr_write_to_summary_csv(writeFold, suv)
roi_name = {suv(1).value.full_name};
sub_name = {suv.name};
stt_arr = {suv.status};
num_sub = length(sub_name);
sub_name = [{0}; transpose(sub_name)];
left_header = [sub_name, [{0}; transpose(stt_arr)]];
num_roi = length(roi_name);

% SUV_mean
sub_scr_write_to_summary_csv('SUV_mean.csv');
% SUV_max
sub_scr_write_to_summary_csv('SUV_max.csv');
% SUVR_mean
sub_scr_write_to_summary_csv('SUVR_mean.csv');
% SUVR_max
sub_scr_write_to_summary_csv('SUVR_max.csv');
% OriginalVol
sub_scr_write_to_summary_csv('VOL_Original.csv');

% SUVThresh
if iscell(suv(1).value(1).volLargerSUV)
    thresh = {suv(1).value(1).volLargerSUV{2:end, 1}};
    sub_scr_write_to_summary_csv_with_thresh('VOL_SUV_thresh_');
else
    sub_scr_write_to_summary_csv('VOL_SUV_thresh.csv');
end

% SUVRThresh
if iscell(suv(1).value(1).volLargerSUVR)
    thresh = {suv(1).value(1).volLargerSUVR{2:end, 1}};
    sub_scr_write_to_summary_csv_with_thresh('VOL_SUVR_thresh_');
else
    sub_scr_write_to_summary_csv('VOL_SUVR_thresh.csv');
end

    function sub_scr_write_to_summary_csv(writeFile)
        arr_data = cell(0);
        for i = 1:length(suv)
            switch(writeFile)
                case 'SUV_max.csv'
                    arr_data = [arr_data; {suv(i).value.SUV_max}];
                case 'SUV_mean.csv'
                    arr_data = [arr_data; {suv(i).value.SUV_mean}];
                case 'SUVR_mean.csv'
                    arr_data = [arr_data; {suv(i).value.SUVR_mean}];
                case 'SUVR_max.csv'
                    arr_data = [arr_data; {suv(i).value.SUVR_max}];
                case 'VOL_Original.csv'
                    arr_data = [arr_data; {suv(i).value.volOriginal}];
                case 'VOL_SUV_thresh.csv'
                    arr_data = [arr_data; {suv(i).value.volLargerSUV}];
                case 'VOL_SUVR_thresh.csv'
                    arr_data = [arr_data; {suv(i).value.volLargerSUVR}];
            end
        end
        arr_data = [roi_name; arr_data];
        arr_data = [left_header, arr_data];
        writeFile = fullfile(writeFold, writeFile);
        writetable(cell2table(arr_data), writeFile,'Delimiter',',', 'WriteVariableNames', false);
    end

    function sub_scr_write_to_summary_csv_with_thresh(writeFile)
        arr_data = [];
        % for each subject
        for i = 1:length(suv) % num subject
            switch(writeFile)
                case 'VOL_SUV_thresh_'
                    tad = {suv(i).value.volLargerSUV};
                case 'VOL_SUVR_thresh_'
                    tad = {suv(i).value.volLargerSUVR};
            end
            tad = [tad{:}]; % flat and convert to mat
            keep_idx = 2:2:size(tad,2);
            tad = tad(2:end, keep_idx);
            arr_data = [arr_data, tad];
        end
        
        all_data = cell(1);
        num_thresh = size(arr_data,1);
        for i =1:num_thresh
            all_data{i} = reshape(arr_data(i,:), num_roi, num_sub)';
            all_data{i} = [roi_name; all_data{i}];
            all_data{i} = [left_header, all_data{i}];
            writeFile2 = fullfile(writeFold, [writeFile num2str(thresh{i}) '.csv']);
            writetable(cell2table(all_data{i}), writeFile2,'Delimiter',',', 'WriteVariableNames', false);
        end
    end
end

