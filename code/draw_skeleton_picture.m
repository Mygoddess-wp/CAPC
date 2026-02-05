function  draw_skeleton_picture(dataset_Name)

addpath(fullfile('.','SO3_curve'))

% dataset_Name = 'UTKinect';
allData_Path = fullfile('..','..','Data');

load(fullfile(allData_Path, 'data', dataset_Name, 'body_model.mat'));
load(fullfile(allData_Path, 'data', dataset_Name, 'skeletal_data.mat'));

all_sigma = {'0.8'};
select_subject_dirName = '';
select_one = '';

% noWeight_or_hasWeight == 1 是无权重，2是有权重
for noWeight_or_hasWeight=1:2
% final result
if noWeight_or_hasWeight == 1
    datasetName_other_descri = '-minFeatVector-centerZ-no0-noTimeWeight';
else
    datasetName_other_descri = '-minFeatVector-centerZ-no0-hasTimeWeight';
end




for sigma_idx = 1:1
sigma = all_sigma{sigma_idx};

if strcmp(dataset_Name,'UTKinect')
    action_number = 10;
    timeWindow = '74';
    sample_number = 199;
    real_sample_number = 100;
    frame_number =74;
    bones_number = 19;
end


data_dir = fullfile(allData_Path, [dataset_Name, '_experiments', datasetName_other_descri], 'output', ...
    ['saveWeight_parts_0_WeightShare_initPPCBySubject_output_sigma_param_', sigma, '_timeWindow_1-', timeWindow],select_subject_dirName,select_one);
    



%% so3 转化成 3D坐标
ppc_data = cell(action_number,1);
ppc_label = zeros(action_number,1);
real_label = zeros(real_sample_number,1);

data_real = zeros(3,3,str2num(timeWindow),bones_number,real_sample_number);
data_generated = zeros(3,3,frame_number,bones_number,action_number);
real_sample_idx = 1;
gen_sample_idx = 1;
% for action_idx=1:action_number
for action_idx=2:3
    load(fullfile(data_dir, ['curve_exper4_action', num2str(action_idx), '_1.mat']));

    real_data_idxs = find(label_ind == 1);
    
    saveImageName = 'SO3_Riemannian_Trajectory.png';
    
    real_data = zeros(3,3,str2num(timeWindow),size(principal_curve,4),size(C,3)/str2num(timeWindow));
    for line_idx=1:size(principal_curve,4)
        C_line = C(:,:,:,line_idx);
        real_data(:,:,:,line_idx,:) = reshape(C_line, size(C_line,1), size(C_line,2), str2num(timeWindow), size(C_line,3)/str2num(timeWindow)); 
    end
    data_real(:,:,:,:,real_sample_idx: real_sample_idx + size(C,3)/str2num(timeWindow) - 1 ) = real_data(:,:,:,:,:);
    real_label(real_sample_idx: real_sample_idx + size(C,3)/str2num(timeWindow) - 1) = ones(size(C_line,3)/str2num(timeWindow),1) * action_idx;
    data_generated(:,:,:,:,gen_sample_idx) = principal_curve;
    ppc_label(gen_sample_idx) = action_idx;

    real_sample_idx = real_sample_idx + size(C,3)/str2num(timeWindow);
    gen_sample_idx = gen_sample_idx + 1;

    generated_data = zeros([size(principal_curve), 2]);
    generated_data(:,:,:,:,1) = principal_curve;
    generated_data = cat(5, principal_curve, principal_curve);

    bone_idx = 10;
    data_SO3 = squeeze(real_data(:,:,:,bone_idx,:));
    sz = size(data_SO3); 
    data_SO3 = reshape(data_SO3, sz(1), sz(2), sz(3) * sz(4));

    realSample_idx = 1;

    load(fullfile(allData_Path, [dataset_Name, '_experiments', datasetName_other_descri],'joint_angles_quaternions','action_line_normal_vector_minFeatVector.mat'))
     
      
    realData_sample_idx = 1;
    bone1_mean_vector_one = real(squeeze(action_line_normal_vector(action_idx,:,:,:)));
    joint_locations = angleR_2_location_vector(principal_curve ,body_model,bone1_mean_vector_one);

    smooth_if = '_smooth5';
    saveActionDir = fullfile(data_dir,['draw',smooth_if],'picture');
    if ~exist(saveActionDir,'dir')
        mkdir(saveActionDir);
    end
    frame_start = 1;
    frame_end = 30;
    red_frames = [];
    color_red_frames = 'k';

    if action_idx == 2  % 动作2的异常帧
        frame_start = 15;
        frame_end = 34;
        red_frames = [7,8,9,10,14,15,16,17,18];
        if noWeight_or_hasWeight == 1
            color_red_frames = 'r';
        else
            color_red_frames = 'g';
        end 
    elseif action_idx == 3 % 动作3的异常帧
        frame_start = 7;
        frame_end = 26;
        red_frames = [3,4,5,15,16,17,18];
        if noWeight_or_hasWeight == 1
            color_red_frames = 'r';
        else
            color_red_frames = 'g';
        end 
    end

    saveVideoName = fullfile(saveActionDir,['gen_action',num2str(action_idx),'_frame-',num2str(frame_start),'-',num2str(frame_end)]);

    window_size = 7; 
    poly_order = 3;  
    inertia_factor = 0.9; 
    if strcmp(smooth_if,'_smooth5')
        joint_locations = smooth_skeleton_data(joint_locations, window_size, poly_order);
    end
    joint_locations = joint_locations(:,:,frame_start:frame_end);

    display_skeleton_traject_3D_english(joint_locations,saveVideoName,body_model)
    
     %% 20帧动作片段示意图生成
    saveActionDir = fullfile(data_dir,['draw',smooth_if],'MultActionPicture');
    if ~exist(saveActionDir,'dir')
        mkdir(saveActionDir);
    end
    cols = 10; 
    generate_len = size(joint_locations, 3); 
    rows = ceil(generate_len / cols); 

    saveVideoName = fullfile(saveActionDir,['gen_action',num2str(action_idx),'_rows',num2str(rows),'_cols',num2str(cols)]);

    display_skeleton_traject_picture(joint_locations, saveVideoName, body_model, rows, cols, red_frames, color_red_frames)


end


end
end

end

