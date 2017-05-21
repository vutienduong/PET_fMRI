% clear;
function scr_write_to_Excel(saved_folder, list_file)
% load list_file2.mat
% saved_folder = 'D:\RESEARCH\spm8\toolbox\aal\saved\49 correct segment May\2';

% load list_file_49_correct_segment.mat

excelFilename = fullfile(saved_folder, 'volume.xlsx');
sheet = 1;

if exist('list_file', 'var')
    
    % rename Sheets
%     if exist(excelFilename, 'file') ~= 2
%         xlswrite(excelFilename,1); % # create test file
%     end
%     e = actxserver('Excel.Application'); % # open Activex server
%     ewb = e.Workbooks.Open(excelFilename); % # open file (enter full path!)
%     ewb.Worksheets.Item(1).Name = 'SUVR > ...'; % # rename 1st sheet
%     ewb.Worksheets.Item(2).Name = 'SUV > ...'; % # rename 2nd sheet
%     ewb.Worksheets.Item(3).Name = 'Original Volume'; % # rename 3rd sheet
%     ewb.Save % # save to the same file
%     ewb.Close(false)
%     e.Quit
    
    for typeVol = 1:3
        sheet = typeVol;
        title_arr = {'Name', 'Status'};
        title_created = 0;
        % write subject name, status and ROI volume for each subject

        order_num = 0; % order of patient
        for i=1:length(list_file)
            name = ['SUV_' list_file(i).name];
            filename = [ name '.mat'];
            if exist( fullfile(saved_folder, filename), 'file')
                order_num = order_num + 1;  % update order of patient

                load(fullfile(saved_folder, filename)); % load SUV file

                % assign suvTemp for convenient processing
                eval(sprintf('suvTemp = %s;', name));

                % create ROI name title (ONCE ONLY)
                if ~title_created
                    for j=1:length(suvTemp)
                        title_arr{1, 2+j} = suvTemp(j).full_name;
                    end

                    % write title from B1
                    xlswrite(excelFilename, title_arr, sheet, 'B1');

                    % update already created title status
                    title_created = 1;
                end

                % convert status from number to text
                if list_file(i).status > 0
                    status = 'POSITIVE';
                else
                    status = 'NEGATIVE';
                end

                % create cell stored data needed writing
                A = {list_file(i).name, status};
                xlRange = sprintf('B%d', order_num + 1);

                % add each ROI volume to cell A
                for j=1:length(suvTemp) % SUVR
                    if typeVol == 1
                        A{1, 2+j} = [suvTemp(j).otherInfo.largerSuvrThresh];
                    elseif typeVol == 2 % SUV
                        A{1, 2+j} = [suvTemp(j).otherInfo.largerSuvThresh];
                    else
                        A{1, 2+j} = [suvTemp(j).otherInfo.original];
                    end
                end

                % write data to Excel
                xlswrite(excelFilename,A,sheet,xlRange);


                % inform success writing
                disp(['Write ' name]);

                % clear uneccessary variable longer
                clear suvTemp;
                eval(sprintf('clear %s;', name));
            end
        end
    end
    disp(['[SUCCESS] Finish write Volume to file: ' excelFilename])
end