function roi_ids = scr_select_roi_def_file()
	DEFAULT_ROI_FILE = 'D:\LEARN\fMRI\spm8\toolbox\aal\ROI_MNI_V4.txt';
	if exist(DEFAULT_ROI_FILE, 'file') == 2
		roifile = uigetfile('.txt' ,'Load the ROI definition file (ROI_MNI_V4.txt)!',...
			  'D:\LEARN\fMRI\spm8\toolbox\aal\ROI_MNI_V4.txt');
	else
		roifile = uigetfile('.txt' ,'Load the ROI definition file (ROI_MNI_V4.txt)!');
	end

	t = readtable(roifile,'Delimiter','\t','ReadVariableNames',false);
	t.Properties.VariableNames = {'Abbr' 'roi_name' 'ID'};
	roi_name = t.roi_name;

	[s,v] = listdlg('PromptString','Select a ROI to save:',...
					'SelectionMode','multiple',...
					'ListString',roi_name,...
					'Name', 'Select ROIs',...
					'ListSize',[200 300]);
	roi_ids = t.ID(s);				
end