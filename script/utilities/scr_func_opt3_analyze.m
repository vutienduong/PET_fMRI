function suvall = scr_func_opt3_analyze( suv, list_file )
    nrun = length(suv);
    i=1;
    while isempty(suv(i).value) && i < nrun
        i=i+1;
    end

    % check index exceeded
    if i > nrun
        return;
    end

    % final var
    suvall = struct('index',{},'full_name',{},'ID',{},'NEG_max',{},'NEG_mean',{},...
    'POS_max',{},'POS_mean',{}, 'POS_max_Avg',{}, 'POS_max_Std',{}, 'POS_mean_Avg',{},...
    'POS_mean_Std',{},'NEG_max_Avg',{},'NEG_max_Std',{},'NEG_mean_Avg',{},...
    'NEG_mean_Std',{});
    [suvall(1:numel(suv(i).value)).index] =     deal(suv(i).value.index);
    [suvall(1:numel(suv(i).value)).full_name] = deal(suv(i).value.full_name);
    [suvall(1:numel(suv(i).value)).ID] =        deal(suv(i).value.ID);

    % add data to temp vars
    num_rois = numel(suv(i).value);
    for crun = i : nrun
        if ~isempty(suv(crun).value)
            if list_file(crun).status == -1
                for j=1:num_rois
                    maxval = suv(crun).value(j).SUVR_max;
                    meanval = suv(crun).value(j).SUVR_mean;
                    if checkNotNullOrZero(maxval)
                        suvall(j).NEG_max(end+1) = maxval;
                    end
                    if checkNotNullOrZero(meanval)
                        suvall(j).NEG_mean(end+1) = meanval;
                    end
                end
            else
                for j=1:num_rois
                   maxval = suv(crun).value(j).SUVR_max;
                    meanval = suv(crun).value(j).SUVR_mean;
                    if checkNotNullOrZero(maxval)
                        suvall(j).POS_max(end+1) = maxval;
                    end

                    if checkNotNullOrZero(meanval)
                        suvall(j).POS_mean(end+1) = meanval;
                    end
                end
            end
        end
    end

    % calculate avg and std
    for j=1:num_rois
        suvall(j).POS_max_Avg = mean(suvall(j).POS_max);
        suvall(j).POS_max_Std = std(suvall(j).POS_max);
        suvall(j).POS_mean_Avg = mean(suvall(j).POS_mean);
        suvall(j).POS_mean_Std = std(suvall(j).POS_mean);

        suvall(j).NEG_max_Avg = mean(suvall(j).NEG_max);
        suvall(j).NEG_max_Std = std(suvall(j).NEG_max);
        suvall(j).NEG_mean_Avg = mean(suvall(j).NEG_mean);
        suvall(j).NEG_mean_Std = std(suvall(j).NEG_mean);
    end

    % remove redundant temporal fields
    fields = {'POS_max','POS_mean','NEG_max','NEG_mean'};
    suvall = rmfield(suvall,fields);

    % remove Std fields unless necessary
    fields = {'POS_max_Std','POS_mean_Std','NEG_max_Std','NEG_mean_Std'};
    suvall = rmfield(suvall,fields);

end

