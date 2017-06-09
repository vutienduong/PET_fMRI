remember to change in "step2_job.m" before "runStep1234":

matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               'D:\RESEARCH\spm8\tpm\grey.nii'
                                               'D:\RESEARCH\spm8\tpm\white.nii'
                                               'D:\RESEARCH\spm8\tpm\csf.nii'
                                               };

=>
matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               '[your location]... \spm8\tpm\grey.nii'
                                               '[your location]... \spm8\tpm\white.nii'
                                               '[your location]... \spm8\tpm\csf.nii'
                                               };