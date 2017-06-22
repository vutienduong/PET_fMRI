function var_value = scr_read_setting( file_name, var_name )
    var_value = 0;
    if exist(file_name, 'file')
        t = readtable(file_name,'Delimiter','\t','ReadVariableNames',true);
        deftSet = containers.Map(t.VAR_NAME,t.VAR_VALUE);
        var_value = deftSet(var_name);
    end
end

