function scr_write_log( log_file, content, mode, varargin)
%SCR_WRITE_LOG Write content to a file
% mode: 'w' or 'a'
% varargin: 1: format
fileID = fopen(log_file,mode);
if isempty(varargin)
    fprintf(fileID,content);
else
    fprintf(fileID,varargin{1}, content);
end
fclose(fileID);
end

