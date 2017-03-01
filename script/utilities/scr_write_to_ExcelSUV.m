clear;
% load list_file2.mat
% saved_folder = 'D:\LEARN\fMRI\spm8\toolbox\aal\saved';
% excelFilename = fullfile(saved_folder, 'testdata.xlsx');

load list_file3.mat
saved_folder = 'D:\LEARN\fMRI\spm8\toolbox\aal\saved_40_addition';
excelFilename = fullfile(saved_folder, 'testdataSuv.xlsx');

sheet = 1;
SUV_id = {'SUV_max', 'SUV_mean', 'SUVR_max', 'SUVR_mean'};

if exist('list_file', 'var')
    title_arr = {'Name', 'Status'};
    title_created = 0;
    % write subject name, status and ROI volume for each subject
    
    order_num = 0; % order of patient
    for i=1:length(list_file)
        name = ['SUV_' list_file(i).name];
        filename = [ name '.mat'];
        if exist( fullfile(saved_folder, filename), 'file')
            order_num = order_num + 1;  % update order of patient
           
            load(filename); % load SUV file
            
            % assign suvTemp for convenient processing
            eval(sprintf('suvTemp = %s;', name));
            
            % create ROI name title (ONCE ONLY)
            if ~title_created
                for j=1:length(suvTemp)
                    title_arr{1, 2+j} = suvTemp(j).full_name;
                end
                
                % write title from B1
                for j=1:4
                    % xlswrite(excelFilename, title_arr, sheet, 'B1');
                    xlswrite(excelFilename, title_arr, j, 'B1');% sheet j-th
                end
                
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
            A = cell(1,4);
            for j=1:4
                A{1,j} = {list_file(i).name, status};
                xlRange = sprintf('B%d', order_num + 1);

                % add each ROI volume to cell A
                for k=1:length(suvTemp)
                    eval(sprintf('A{1,j}{1, 2+k} = [suvTemp(k).%s];', SUV_id{1,j}));
                end

                % write data to Excel
                xlswrite(excelFilename,A{1,j},j,xlRange);% sheet j-th
            end
            
            
            % inform success writing
            disp(['Write ' name]);
            
            % clear uneccessary variable longer
            clear suvTemp;
            eval(sprintf('clear %s;', name));
        end
    end
end