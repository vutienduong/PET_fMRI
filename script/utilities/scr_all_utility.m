function varargout = scr_all_utility( func, varargin )
%SCR_ALL_UTILITY Summary of this function goes here
%   Detailed explanation goes here
switch(func)
    case 'assignVolumeFollowThresh'
        % assignVolumeFollowThresh(thr, nonZerosVox, multiplier, VOX_UNIT)
        thr = varargin{1};
        nonZerosVox = varargin{2};
        multiplier = varargin{3};
        VOX_UNIT = varargin{4};
        if length(thr) > 1
            tsuv = cell(1);
            tsuv{1,1} = 'thresh';
            tsuv{1,2} = 'volume';
            for j=1:length(thr)
                tsuv{j+1,1} = thr(j);
                tsuv{j+1,2} = sum(nonZerosVox > thr(j) / multiplier) * VOX_UNIT;
            end
            varargout{1} = tsuv;
        else
            varargout{1} = sum(nonZerosVox > thr(1) / multiplier) * VOX_UNIT;
        end
end

end

