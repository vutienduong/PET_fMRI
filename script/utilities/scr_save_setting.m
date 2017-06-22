function scr_save_setting(a_key, a_val)
setting_file = 'history_default.txt';
t = readtable(setting_file,'Delimiter','\t','ReadVariableNames',true);
deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
if isnumeric(a_val)
    a_val = num2str(a_val);
end
deftSet(a_key) = a_val;

str = 'VAR_NAME\tVAR_VALUE\n';
s_strs = keys(deftSet);
value_arr = values(deftSet);
value_arr = strrep(value_arr, '\', '\\');
for i =1:length(value_arr)
    str = [ str s_strs{1,i} '\t' value_arr{1,i} '\n'];
end

fileID = fopen(setting_file,'w'); % TODO: directly path
fprintf(fileID,str);
fclose(fileID);