
function smoothed_data = smooth_skeleton_data(skeleton_data, window_size, poly_order)

    if size(skeleton_data, 1) ~= 3
        error('输入数据的第一维度必须为3，表示x, y, z坐标');
    end
    [num_coords, num_nodes, num_frames] = size(skeleton_data);

    smoothed_data = zeros(size(skeleton_data));

    for coord = 1:num_coords
        for node = 1:num_nodes
            time_series = squeeze(skeleton_data(coord, node, :));
            smoothed_series = sgolayfilt(time_series, poly_order, window_size);
            smoothed_data(coord, node, :) = smoothed_series;
        end
    end
end
