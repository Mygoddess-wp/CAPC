
function generate_PPCData(allData_Path,dataset_Name,ppc_genFrame,set_max_iter,exper_param_left , exper_param_right , action_param_left, action_param_right, sigma_param, time_param_left, time_param_right,hasWeight)



Absolute_allData_Path = fullfile(pwd, allData_Path);
disp(['Absolute Data Path: ', Absolute_allData_Path]);

disp('--- Function Parameters ---');
disp(['All Data relative Path: ', allData_Path]);
disp(['Dataset Name: ', dataset_Name]);
disp(['PPC Generate Frame: ', num2str(ppc_genFrame)]);
disp(['Set Max Iteration: ', num2str(set_max_iter)]);
disp(['Exper Param Left: ', num2str(exper_param_left)]);
disp(['Exper Param Right: ', num2str(exper_param_right)]);
disp(['Action Param Left: ', num2str(action_param_left)]);
disp(['Action Param Right: ', num2str(action_param_right)]);
disp(['Sigma Param: ', num2str(sigma_param)]);
disp(['Time Param Left: ', num2str(time_param_left)]);
disp(['Time Param Right: ', num2str(time_param_right)]);
disp('----------------------------');

if hasWeight == 0
    datasetName_other_descri = '-minFeatVector-centerZ-no0-noTimeWeight';
else
    datasetName_other_descri = '-minFeatVector-centerZ-no0-hasTimeWeight';
end

if ~isfolder(allData_Path)
    error('指定的路径不存在：%s', allData_Path);
end

filesAndFolders = dir(allData_Path);
filesAndFolders = filesAndFolders(~ismember({filesAndFolders.name}, {'.', '..'}));

saveDirName = ['output/saveWeight_parts_0' ,...
    '_WeightShare_initPPCBySubject_output_sigma_param_', num2str(sigma_param),...
    '_timeWindow_',num2str(time_param_left),'-',num2str(time_param_right)];


load(fullfile(allData_Path, 'data', dataset_Name, 'body_model.mat'));
load(fullfile(allData_Path, 'data', dataset_Name, 'skeletal_data.mat'));
load(fullfile(allData_Path, 'data', dataset_Name, 'subject.mat'));
load(fullfile(allData_Path, 'data', dataset_Name, 'desired_frames.mat'));

disp(['desired_frames = ',num2str(desired_frames)])

curvepoints=body_model.joint_angle_pairs;
bone1_joints=curvepoints(:,1:2);
n_angles = size(bone1_joints, 1);


disp('目录和文件列表:');
for k = 1:length(filesAndFolders)
    disp(filesAndFolders(k).name)
    if filesAndFolders(k).isdir
        fprintf('文件夹: %s\n', filesAndFolders(k).name);
        if strcmp(filesAndFolders(k).name,[dataset_Name,'_experiments',datasetName_other_descri])
            folderPath_one = fullfile(allData_Path, filesAndFolders(k).name, saveDirName);
            if ~exist(folderPath_one, 'dir')
                mkdir(folderPath_one);
            end
            subFolder = fullfile(allData_Path, filesAndFolders(k).name);
            subFiles = dir(subFolder);
            
            for exper=exper_param_left:exper_param_right
                for action=action_param_left:action_param_right
                    for line=1:n_angles/2
                        T = ppc_genFrame;
                        if strcmp(dataset_Name,'MHAD')
                            T = desired_frames(action);
                            time_param_right = desired_frames(action);
                        end
                        sigma = sigma_param;
                        max_iter = set_max_iter;
                        load(fullfile(allData_Path, filesAndFolders(k).name, ...
                                    ['exper', num2str(exper), '_action', num2str(action), '_line', num2str(line), '.mat']));
                        number = size(C,3);
                        frame_number = desired_frames(action);
                        number = number / frame_number;
                        select_timeWindow = [];
                        C_idxSets = 1:number;
                        for time_i=C_idxSets
                            timeWindow = time_param_left+(time_i-1)*frame_number : frame_number*(time_i-1) + time_param_right;
                            select_timeWindow = [select_timeWindow timeWindow];
                        end
                        select_timeWindow_C = C(:,:,select_timeWindow);
                        subject_sets = subject(find(label_ind == 1));
                        subject_sets = subject_sets(C_idxSets);
                        C1(:,:,:,line)=select_timeWindow_C;
                    end
                    C = C1;
                    [principal_curve,all_weights,initialize_time_indice] = RiemannianPrincipalCurve_WeightShare(C, T, sigma, max_iter, subject_sets,hasWeight);
                    save(fullfile(allData_Path, filesAndFolders(k).name, saveDirName, ...
                                    ['curve_exper', num2str(exper), '_action', num2str(action), '_1.mat']), ...
                                    'principal_curve', 'C', 'label_ind', 'all_weights', 'initialize_time_indice', ...
                                    'select_timeWindow', 'time_param_left', 'time_param_right', 'subject_sets');

                    disp(['finish exper' num2str(exper) ' finsh action' , num2str(action)]);
                end
            end
        end
    end
end

end

