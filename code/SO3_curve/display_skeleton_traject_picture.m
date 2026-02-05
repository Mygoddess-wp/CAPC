function display_skeleton_traject_picture(joint_locations, outputImageName, body_model, rows, cols,red_frames,color_red_frames)
  
    generate_len = size(joint_locations, 3); 
    total_frames = min(generate_len, rows * cols); 

    gap = 0.005; 
    if rows == 1
        top_gap = 0.2; 
    else
        top_gap = 0.1; 
    end
    window_width = cols * 150; 
    window_height = (rows *(1 + gap)) * 150; 
    figure('Position', [400, -400, window_width, window_height *(1 + top_gap)]); 
    
    for frame = 1:total_frames 

        row_idx = floor((frame - 1) / cols); 
        col_idx = mod(frame - 1, cols); 

        left_pos = col_idx * (1 / cols);
        bottom_pos = 1 - (((row_idx + 1) * (1 / rows) - gap / 2)*(1 - top_gap) + top_gap); 
        ax = axes('Position', [left_pos, bottom_pos, 1 / cols, (1 / rows - gap)*(1 - top_gap)]);

        scatter3(joint_locations(1, :, frame), joint_locations(2, :, frame), joint_locations(3, :, frame), ...
            8,'filled');
        hold on;

        x = joint_locations(1, :, frame);
        y = joint_locations(2, :, frame);
        z = joint_locations(3, :, frame);


        if ismember(frame, red_frames)
            line_color = color_red_frames;  
        else
            line_color = 'k'; 
        end
        conn = body_model.bones; 
        for i = 1:size(conn, 1)
            node1 = conn(i, 1);
            node2 = conn(i, 2);
            x = [joint_locations(1, node1, frame), joint_locations(1, node2, frame)];
            y = [joint_locations(2, node1, frame), joint_locations(2, node2, frame)];
            z = [joint_locations(3, node1, frame), joint_locations(3, node2, frame)];

            plot3(x, y, z, line_color, 'LineWidth', 2);
        end

        xlim([-1 1]); 
        ylim([-1 1]); 
        zlim([-1 1]); 
        axis off; 
        xlabel('X轴');
        ylabel('Y轴');
        zlabel('Z轴');
        set(ax, 'FontSize', 35);
        axis equal;
    end

    saveas(gcf, [outputImageName, '.png']); 
    close(gcf); 
    img = imread([outputImageName, '.png']);
    figure;
    imshow(img);
    title("Saved Skeleton Trajectory Image");
    
%     close(gcf); % 原始绘图窗口可以关掉
end


