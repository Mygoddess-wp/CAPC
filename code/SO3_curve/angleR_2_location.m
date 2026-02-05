
function [joint_locations] = angleR_2_location(rot_mats,body_model,bone1_mean_vector)
    curvepoints=body_model.joint_angle_pairs;
    bone1_joints=curvepoints(:,1:2);
    bone2_joints=curvepoints(:,3:4);
    [~,D,N,n_angles_2]=size(rot_mats);
    n_angles = n_angles_2 * 2;
    generate_len=N;
    joint_locations=zeros(D,n_angles/2,generate_len);
    if N == generate_len
        generate_indice=1:N;
    else
        rand('seed',70);
        generate_indice=sort(randi([1 N],1,generate_len));
    end
    bone_length=body_model.bone_lengths;
    
    for frame=1:generate_len
        for i=1:n_angles/2
            PC=rot_mats(:,:,:,i);
            if (bone1_joints(i,2))
                bone1_global = joint_locations(:, bone1_joints(i, 2),frame) - joint_locations(:, bone1_joints(i, 1),frame);
            else
                bone1_global = [1 0 0]' - joint_locations(:, bone1_joints(i, 1),frame);
            end
    
            R = vrrotvec2mat(vrrotvec(bone1_global, [1, 0, 0]));
            RT=PC(:,:,generate_indice(frame));
            bone2_global=R'*RT/sqrtm(RT'*RT)*[1 0 0]'*bone_length(i);
            joint_locations(:, bone2_joints(i, 2),frame) = bone2_global + joint_locations(:, bone2_joints(i, 1),frame);
        end
        
    end
end



