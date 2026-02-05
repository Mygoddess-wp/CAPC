function display_skeleton_traject(joint_locations,saveVideoName,body_model)

    outputVideo = VideoWriter(saveVideoName,'MPEG-4');
    outputVideo.FrameRate = 10; 
    open(outputVideo);  
    generate_len = size(joint_locations,3);
    for frame=1:generate_len 
        figure('Visible', 'off');
        scatter3(joint_locations(1,:,frame),joint_locations(2,:,frame),joint_locations(3,:,frame))
        hold on;
        x = joint_locations(1,:,frame);
        y = joint_locations(2,:,frame);
        z = joint_locations(3,:,frame);
        for i = 1:length(x)
            text(x(i), y(i), z(i), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        end
        conn=body_model.bones;
        for i = 1:size(conn, 1)
            node1 = conn(i, 1);
            node2 = conn(i, 2);
            x = [joint_locations(1,node1,frame), joint_locations(1,node2,frame)];
            y = [joint_locations(2,node1,frame), joint_locations(2,node2,frame)];
            z = [joint_locations(3,node1,frame), joint_locations(3,node2,frame)];
            plot3(x, y, z, 'k-', 'LineWidth', 2);
        end
        xlim([-1 1]);
        ylim([-1 1]); 
        zlim([-1 1]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');

        frame = getframe(gcf);
        writeVideo(outputVideo, frame);
        close(gcf);
    end
    close(outputVideo);
    

end

