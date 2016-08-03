load list_file
%read WM of MRI
cur_path = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\testcode\';
detail_var = struct();
type = {'pet', 'fmri'};
i=1;
for idx =1:length(list_file)
	for j=1:2
        fprintf('%d ', i); 
		eval(['file_name= list_file(idx).' type{1,j} ';']);
		fnms1 = [cur_path file_name ',1'];
		hdr1 = spm_vol(deblank(fnms1));
		oimg = spm_read_vols(hdr1);
		
		detail_var(i).max_inten = max(oimg(:));
		detail_var(i).min_inten = min(oimg(:));
		detail_var(i).dim = size(oimg);
		detail_var(i).type = class(oimg);
		detail_var(i).uni_val = length(unique(oimg));
		detail_var(i).non_zero = length(find(oimg));
        detail_var(i).name = list_file(idx).name;
        detail_var(i).type = type{1,j};
        i=i+1;
	end
end
disp('');
