function mapStt = scr_get_Status()
keySet = {'AN_YEONG_SUN', 'BAK_JEONG_SUN','CHO_KYEONG_JA','JEON_YEONG_TAE',...
    'JI_BYEONG_O','KIM_BYEONG_HAG','KIM_JEOM_SUN','KIM_MYEONG_SEON',...
    'KIM_MYEONG_WEON','KIM_SAM_SEOG','KIM_SEONG_HOO','KIM_YEONG_KIL',...
    'KIM_YONG_KI','KO_JEOM_SUK','MA_IN_HWA','YUN_HYEONG_SIK','YUN_KI_JA',...
	'JEONG_SEUNG_JOO',...
	'CHOO_PAN_RYE',...
	'PARK_JAE_WON',...
	'PARK_YEONG_KYUN',...
	'HEO_JEONG_JIN',...
	'KIM_JEONG_JA',...
	'KIM_BOO_DEOG',...
	'CHOI_SANG_OG',...
	'KIM_KYEONG_SEON',...
	'KIM_YONG_RYE',...
	'YANG_DONG_BOG',...
	'RYU_HANG_RYEOL',...
	'CHOI_HYE_SOOG',...
	'PARK_HAN_KEUM',...
	'KIM_CHOONG_SEOB',...
	'LEE_YONG_JU',...
	'SEO_SAENG_SEOG',...
	'PARK_SANG_KI',...
	'MIN_JE_PYEONG',...
	'CHA_HEE_20160704',...
	'PARK_MYEON_JOO',...
	'PARK_HYE_SEOK',...
	'JANG_WOONG_KI',...
	'YOO_HEE_JONG',...
	'PARK_HWA_SOON',...
	};
valueSet = {-1,1,-1,1,1,1,1,-1,1,-1,-1,1,1,-1,-1,-1,1, ...
    -1,1,1,-1,1,-1,-1,1,1,1,1,1,-1,1,1,1,-1,-1,1,1,1,-1,1,-1,-1};
mapStt = containers.Map(keySet,valueSet);