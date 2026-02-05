clear all;
close all;

addpath(fullfile('.','gen_SO3_curve'))
%% 有无权重参数选择
hasWeight = 0; % 0 代表没有权重，1代表有权重

%%
rng(42);
amplitude = 1;% 正弦波幅度
frequency = 2;% 正弦波频率（周期数）
T = 100; % 主曲线的点数
noise_level =  0.1;  % 噪声水平
N = 800;            % 样本数量
max_iter = 10;
sigma = 0.01;

% 生成曲线数据
data_1 = generate_sin_curve_on_unit_sphere(N, amplitude, frequency, noise_level);
so3_data_1 = generate_so3_from_sphere(data_1,N, amplitude, frequency, noise_level);
so3_data_new = so3_data_1(:,:,[1:N/2, N:-1:N/2+1]);
so3_data_1 = so3_data_new(:,:,1:N/2);

data = so3_data_1;
[principal_curve] = RiemannianPrincipalCurve(data(:,:,:), T, sigma, max_iter,hasWeight);


visualize_principal_curve(data(:,:,:), principal_curve(:,:,:));


function visualize_principal_curve(data_so3, principal_curve_so3)

    data_points = project_so3_to_unit_sphere(data_so3);
    principal_curve_points = project_so3_to_unit_sphere(principal_curve_so3);

    figure;
    view(3);
    hold on;

    [X, Y, Z] = sphere(50);
    sphereColor = [0.75, 0.75, 0.75];
    surf(X, Y, Z, ...
        'FaceAlpha', 0.5, ... 
        'EdgeColor', 'none', ... 
        'FaceColor', sphereColor, ... 
        'AmbientStrength', 0.3, ...  
        'DiffuseStrength', 0.8);  
    
    lighting gouraud;
    light('Position', [1 1 1], 'Style', 'infinite');
    material dull;
    
    n_points = size(data_points, 1);
    n_curve_points = size(principal_curve_points, 1);

    colors = parula(n_points); 

    for i = 1:n_points
        scatter3(data_points(i, 1), data_points(i, 2), data_points(i, 3), ...
                 30, colors(i, :), 'filled', 'DisplayName', 'Data Points');
    end
    
    curve_color = [1, 0, 0]; 
    hCurve = plot3(principal_curve_points(:, 1), ...
          principal_curve_points(:, 2), ...
          principal_curve_points(:, 3), '-', ...
          'Color', curve_color, ...
          'LineWidth', 2.5, 'DisplayName', 'Principal Curve');

    font_size = 15;
    xlabel('X', 'FontSize', font_size, 'FontName', 'Times New Roman');
    ylabel('Y', 'FontSize', font_size, 'FontName', 'Times New Roman');
    zlabel('Z', 'FontSize', font_size, 'FontName', 'Times New Roman');

    legend_handle = legend([hCurve; scatter3(nan, nan, nan, 30, 'filled', 'DisplayName', 'Data Points')], ...
               'Principal Curve', 'Data Points');
    set(legend_handle, 'FontSize', font_size, 'FontName', 'Times New Roman');

    axis equal;
    grid on;
    hold off;

end


function projected_points = project_so3_to_unit_sphere(so3_data)
    
    N = size(so3_data, 3); 
    projected_points = zeros(N, 3);

    for k = 1:N
        R = so3_data(:, :, k); 
        theta = acos((trace(R) - 1) / 2); 
        if abs(theta) > 1e-6
            w = (1 / (2 * sin(theta))) * [R(3, 2) - R(2, 3);
                                          R(1, 3) - R(3, 1);
                                          R(2, 1) - R(1, 2)];

            w = w / norm(w); 
            projected_points(k, :) = w;
        else
            projected_points(k, :) = [1, 0, 0];
        end
    end
end

function so3_data = generate_so3_from_sphere(data,N, amplitude, frequency, noise_level)

    so3_data = zeros(3, 3, N); 

    t = linspace(0, 2*pi, N);

    base_angles = amplitude * sin(frequency * t);

    if noise_level > 0
        angles = base_angles + normrnd(0, noise_level, 1, N);
    else
        angles = base_angles;
    end

    curvature = zeros(1, N);
    for i = 2:N-1
        v1 = data(i,:) - data(i-1,:);
        v2 = data(i+1,:) - data(i,:);
        curvature(i) = acos(max(min(dot(v1,v2)/(norm(v1)*norm(v2)),1),-1));
    end
    curvature(1) = curvature(2);
    curvature(N) = curvature(N-1);
    
    k = 0.3; 
    adjusted_angles = angles + k * curvature;
    
    max_angle = pi/2;
    normalized_angles = adjusted_angles * max_angle / max(abs(adjusted_angles));
    
    arc_lengths = zeros(1, N);
    for i = 2:N
        arc_lengths(i) = arc_lengths(i-1) + norm(data(i,:) - data(i-1,:));
    end
    
    angles = 2 * pi * arc_lengths / arc_lengths(end);
    normalized_angles = angles;

    for i = 1:N
        axis_1 = data(i, :);
        
        axis_1 = axis_1 / norm(axis_1);

        theta = normalized_angles(i);
        so3_data(:, :, i) = axis_angle_to_rotation_matrix(axis_1, theta);
    end

end

function data = generate_sin_curve_on_unit_sphere(N, amplitude, frequency, noise_level)
    
    theta = linspace(0, 2 * pi, N);
    z = amplitude * sin(frequency * theta) + normrnd(0, noise_level, 1, N); 
    z = z / max(abs(z)); 
    r = sqrt(1 - z.^2); 
    x = r .* cos(theta); 
    y = r .* sin(theta);
    data = [x', y', z'];
end


function R = axis_angle_to_rotation_matrix(axis, theta)
    x = axis(1);
    y = axis(2);
    z = axis(3);
    
    c = cos(theta);
    s = sin(theta);
    t = 1 - c;
    R = [
        t * x * x + c,       t * x * y - s * z, t * x * z + s * y;
        t * x * y + s * z,   t * y * y + c,     t * y * z - s * x;
        t * x * z - s * y,   t * y * z + s * x, t * z * z + c
    ];
end

