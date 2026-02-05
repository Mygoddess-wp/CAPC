function visualize_principal_curve(data, principal_curve, hasWeight)
    [D, N] = size(data);
    figure;
    hold on;
    
    [~, sort_idx] = sort(principal_curve(1, :));
    sorted_principal_curve = principal_curve(:, sort_idx);

    data_points_color = [0/255, 114/255, 189/255];
    connection_color = [0/255, 200/255, 50/255];


    curve_color = [217/255, 83/255, 25/255];

    scatter(data(1, :), data(2, :), 40, ...
            data_points_color, ...
            'filled', ...
            'MarkerFaceAlpha', 0.8, ...
            'DisplayName', 'Data Points');

    plot(principal_curve(1, :), principal_curve(2, :), '-', ...
         'Color', curve_color, ...
         'LineWidth', 2.5, ...
         'DisplayName', 'Principal Curve');

    if hasWeight == 0
        plot(sorted_principal_curve(1, :), sorted_principal_curve(2, :), '-', ...
             'Color', connection_color, ...
             'LineWidth', 2.5, ...
             'DisplayName', 'ordered Principal Curve');
    end

    xlabel('x', 'FontSize', 20, 'FontWeight', 'bold','FontName', 'Times New Roman');
    ylabel('y', 'FontSize', 20, 'FontWeight', 'bold','FontName', 'Times New Roman');

    legend_obj = legend('show');
    set(legend_obj, 'FontSize', 17, 'FontWeight', 'bold', 'FontName', 'Microsoft YaHei');

    ax = gca;
    set(ax, 'FontSize', 17, 'FontName', 'Times New Roman');

    grid on;
    axis equal;
    box on;
    hold off;
end