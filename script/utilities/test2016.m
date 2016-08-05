mapStt = scr_get_Status();
patt = '*.img';
 cd('D:\LEARN\2nd SEMESTER\more\PET medical\July 29\additional 41 images & additional 16 images\hdr files changed in same name Eng'); %change current directory to cur_path
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
	list_file(j).name = search_name;
	list_file(j).status = mapStt(search_name);
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