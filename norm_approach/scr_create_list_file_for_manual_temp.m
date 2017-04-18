patt = '*.img';
cur_path = 'D:\RESEARCH\spm8\toolbox\aal\demo\hdr files changed in same name Eng'; % TODO: hardcode, test
cd(cur_path); %change current directory to cur_path
mapStt = scr_get_Status();
list_file = struct(); % include fmri and pet fields in each element
list = dir(patt); % NOTE: current directory
j = 1;

while ~isempty(list)
    assign_pet = false;
    temp = list(1).name;
    if strfind(temp, 'PTCT_FLORBETABEN') % check this is PET or MRI
        list_file(j).pet = temp;
        assign_pet = true;
    else
        list_file(j).fmri = temp;
    end

    list(1) = []; % remove considering element
    underscore_index = strfind(temp, '_');
    search_name = temp(1:(underscore_index(3)-1));

    list_file(j).status = mapStt(search_name);
    list_file(j).name = search_name;
    for i=1:length(list)
        if ~isempty(strfind(search_name,'_'))

            if assign_pet % check this is PET or MRI
                list_file(j).fmri = list(i).name;
            else
                list_file(j).pet = list(i).name;
            end
            list(i) = [];
            break;
        end
    end
    j = j +1;
end

% chi giu lai healthy
is_only_healthy = 1; % flag
nrun = length(list_file);
if is_only_healthy
    crun = 1;
    while crun <= length(list_file)
        if list_file(crun).status == 1
            list_file(crun) = [];
        else
            crun = crun + 1;
        end
    end
end

% chi giu lai size tu 41.6 den 48
is_keep_same_mri = 1; % flag
if is_keep_same_mri
    list_need_delete = {'JANG_WOONG_KI', 'KIM_SUN_DEOG', 'PARK_SANG_KI', 'PARK_YEONG_KYUN', 'KIM_BOO_DEOG', 'CHO_HYEON_SUK', 'HEO_JEONG_JIN', 'JEONG_SEUNG_JOO', 'PARK_KU_JI', 'SONG_KIL_SEOB'};
    crun = 1;
    while crun <= length(list_file)
        i = 1;
        is_any_delete = 0;
        while i <= length(list_need_delete)
            if strcmp(list_file(crun).name, list_need_delete(i))
                list_file(crun) = [];
                list_need_delete(i) = [];
                is_any_delete = 1;
                break;
            end
            i = i + 1;
        end

        if ~is_any_delete
            crun = crun + 1;
        end
    end
end