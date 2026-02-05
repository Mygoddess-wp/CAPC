function display_skeleton_traject_3D_english(joint_locations, saveImageName, body_model)
    generate_len = size(joint_locations, 3); 
    gap = -1.5;

    y_min = zeros(1, generate_len);
    y_max = zeros(1, generate_len);
    for frame = 1:generate_len
        y_min(frame) = min(joint_locations(2,:,frame));
        y_max(frame) = max(joint_locations(2,:,frame));
    end

    offsets = zeros(1, generate_len);
    for frame = 2:generate_len
        offsets(frame) = offsets(frame - 1) + (y_max(frame - 1) - y_min(frame - 1)) + gap;
    end

    figure('Visible', 'on', ...
                'Units', 'normalized', ...
                'Position', [0.1 0.1 0.3 0.3]); 
    ax = gca;
    hold on;

    cmap = jet(generate_len);

    for frame = 1:generate_len

        offset = offsets(frame);
        frame_color = cmap(frame, :);
        alpha_val = (frame - 1) / generate_len;

        scatter3(...
            joint_locations(1,:,frame), ...
            joint_locations(2,:,frame) + offset, ...
            joint_locations(3,:,frame), ... 
            36, frame_color, 'filled', 'MarkerFaceAlpha', alpha_val);

        conn = body_model.bones;
        for i = 1:size(conn, 1)
            node1 = conn(i, 1);
            node2 = conn(i, 2);
            x = [joint_locations(1, node1, frame), joint_locations(1, node2, frame)];
            y = [joint_locations(2, node1, frame), joint_locations(2, node2, frame)] + offset;
            z = [joint_locations(3, node1, frame), joint_locations(3, node2, frame)];
            plot3(x, y, z, 'k-', 'LineWidth', 1, 'Color', frame_color, 'LineStyle', '-', 'Color', [frame_color alpha_val]); 
        end


    end

    xlim([-1 1]);
    ylim([1 * (gap + min(offsets)), 1 * (max(offsets) + (y_max(end) - y_min(end)))]);
    zlim([min(joint_locations(3,:,:), [], 'all'), max(joint_locations(3,:,:), [], 'all')]);

    xlabel('X轴');
    ylabel('Y轴 (时间偏移)');
    zlabel('Z轴 (深度)');

    view(3);

    axis off;
    set(ax, 'Position', [0 0 1 1]);

    saveas(gcf, [saveImageName,'.png']);
    crop_percent = 15;
    crop_left_percent = 16;
    crop_right_percent= 11.5;
    crop_top_percent=4;
    crop_bottom_percent=4;
    crop_image_sides([saveImageName,'.png'], [saveImageName,'.png'], crop_left_percent,crop_right_percent,crop_top_percent, crop_bottom_percent)
    close(gcf);
end

