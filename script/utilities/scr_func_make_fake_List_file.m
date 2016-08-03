function list_file = scr_func_make_fake_List_file( listfile )
list_file = struct();
mapStt = scr_get_Status();
for i=1:length(listfile)
    [~,name,~] = fileparts(listfile{i,1});
    name = name(5:end);
    list_file(i).name = name;
    list_file(i).status = mapStt(name);
end
end