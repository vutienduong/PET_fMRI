file_name = {'SPM8_Kim_Byeong_Hag1.mat', 'SPM8_Ma_In_Hwa.mat', 'SPM8_Kim_Yong_Ki1.mat',...
    'SPM8_Ko_Jeom_Suk.mat'};
sub_name = {'KIM_BYEONG_HAG', 'MA_IN_HWA', 'KIM_YONG_KI', 'KO_JEOM_SUK'};
del_name = 'CHO_KYEONG_JA';

for i=1:length(suvTemp)
	if strcmp(suvTemp(i).name, del_name)
		suvTemp(i) = [];
		break;
	end
end

nsub = length(suvTemp)

for i=1:length(sub_name)
	j=1;
	search_name = sub_name{i};
	while j<=nsub
		if strcmp(search_name, suvTemp(j).name)
			load(file_name{i});
			for k =1:12
				suvTemp(j).value(k).SUVR_max= suv(k).SUVR_max;
				suvTemp(j).value(k).SUVR_mean= suv(k).SUVR_mean;
			end
			break;
		end
		j=j+1;
	end
end