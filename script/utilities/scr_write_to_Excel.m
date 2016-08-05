clear;
load list_file2.mat
saved_folder = 'D:\LEARN\fMRI\spm8\toolbox\aal\saved';
excelFilename = fullfile(saved_folder, 'testdata.xlsx');
sheet = 1;

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
            for j=1:length(suvTemp)
                A{1, 2+j} = [suvTemp(j).otherInfo.largerSuvrThresh];
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