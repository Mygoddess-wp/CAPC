clear all;
addpath(fullfile('.','gen_principle_curve'))

%% 有无权重参数选择  + 选择生成数据类型是sin曲线还是抛物线
hasWeight = 1; % 0 代表没有权重，1代表有权重
select_constructData = "sin";
% select_constructData = "parabolic";

%% 
N = 1000;
T = 20; % 主曲线的点数
sigma = 0.08;
max_iter = 100;

if select_constructData == "parabolic"
    % 生成抛物线数据
    coefficient = 2;
    data_1 = generate_poincare_data(N/2, coefficient);
    coefficient = 6/4;
    data_2 = generate_poincare_data(N/2, coefficient);
    coefficient = 5/4;
    data_3 = generate_poincare_data(N/2, coefficient);
    data = [data_1, data_2, data_3];
elseif select_constructData == "sin"
    % 生成sin数据
    amplitude = 2;
    frequency = 1;
    noise_level = 0.5;
    data_1 = generate_sin_poincare_data(N, amplitude, frequency, noise_level);
    data = data_1;
end


[principal_curve,weights] = RiemannianPrincipalCurve(data, T, sigma, max_iter, hasWeight);


row_values = principal_curve(1, :);

[~, idx] = sort(row_values, 'ascend');
sorted_principal_curve = principal_curve(:, idx);
visualize_principal_curve(data, principal_curve,hasWeight);

