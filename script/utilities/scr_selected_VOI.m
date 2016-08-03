% if you want to select other ROIs, 
% please refer 'ROI_MNI_V4.txt' for more abbreviates of ROIs
function [roi_map, varargout] = scr_selected_VOI
roi_names = {'THAD', 'THAG', 'NLG','NLD','CIPG','CIPD','CIAG', 'CIAD',...
'P1G', 'P1D', 'P2G','P2D', 'FRONTAL_WHOLE', 'PARIETAL_WHOLE', 'TEMPORAL_WHOLE', 'OCCIPITAL_WHOLE'};
roi_vals = zeros(1, length(roi_names));
roi_vals = num2cell(roi_vals);
roi_vals{1,13} = [2101,2322, 2601, 2612];
roi_vals{1,14} = [6101, 6202];
roi_vals{1,15} = [8111, 8302];
roi_vals{1,16} = [5101, 5302];
roi_map = containers.Map(roi_names,roi_vals);
if nargout > 1
	varargout{1} = roi_names;
end