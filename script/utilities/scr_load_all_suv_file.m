cur_path = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\testcode\suv';

% check whether folder is exist
if exist(cur_path) == 7
	suv = struct();
	cd(cur_path);
	list = dir('*.mat');
	for i = 1:length(list)
		suv(i).name = list(i).name;
		suv(i).value = load(list(i).name);
	end
	disp('Load all suv files successfully')
else
	disp('Cant load because suv folder is non-exist')
end
