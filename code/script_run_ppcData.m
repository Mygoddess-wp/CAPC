
addpath(fullfile('.','SO3_curve'))

dataset_Name = 'UTKinect';
allData_Path = fullfile('..','..','Data'); 
exper_param_left = 4; 
exper_param_right = 4;
action_param_left = 1;
action_param_right = 10;
sigma_param = 0.8;
time_param_left = 1;

if strcmp(dataset_Name,'UTKinect')
    time_param_right = 74;
    ppc_genFrame = 74;
    set_max_iter = 100;
end
%% 生成人体动作的ppc曲线
% for hasWeight = 0:1 % 0 代表没有权重，1代表有权重
%     % 生成人体动作的ppc曲线
%     generate_PPCData(allData_Path,dataset_Name,ppc_genFrame,set_max_iter, exper_param_left , exper_param_right , action_param_left, action_param_right, sigma_param, time_param_left, time_param_right,hasWeight)
% end
%% 可视化人体动作生成的效果，以及有权重和无权重的对比图
draw_skeleton_picture(dataset_Name)


