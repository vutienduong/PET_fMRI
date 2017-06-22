function config_val = scr_get_config_by_key(file_name, a_keyword)
if ~exist(file_name, 'file')
    file_name = 'history_default.txt';
end
t = readtable(file_name,'Delimiter','\t','ReadVariableNames',true);
deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
config_val = deftSet(a_keyword);