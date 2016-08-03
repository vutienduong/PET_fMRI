load list_file
%read WM of MRI
cur_path = 'D:\LEARN\fMRI\spm8\toolbox\aal\test_data\testcode\';
simp_detail_var = struct();
type = {'pet', 'fmri'};
for i =1:length(list_file)
	simp_detail_var(i).name = list_file(i).name;
	fprintf('%d ', i); 
	for j=1:2
		eval(['file_name= list_file(i).' type{1,j} ';']);
		fnms1 = [cur_path file_name ',1'];
		hdr1 = spm_vol(deblank(fnms1));
		oimg = spm_read_vols(hdr1);
		eval(['simp_detail_var(i).' type{1,j} '=size(oimg);']);
	end
end
sprintf('\n');