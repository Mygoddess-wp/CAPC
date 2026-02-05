
function crop_image_custom(input_path, output_path, crop_left_percent, crop_right_percent, crop_top_percent, crop_bottom_percent)
    try
        [img, ~, alpha] = imread(input_path);

        [height, width, num_channels] = size(img);

        crop_left = round(width * crop_left_percent / 100);
        crop_right = round(width * crop_right_percent / 100);
        crop_top = round(height * crop_top_percent / 100);
        crop_bottom = round(height * crop_bottom_percent / 100);

        new_width = width - crop_left - crop_right;
        new_height = height - crop_top - crop_bottom;

        cropped_img = img(crop_top + 1:height - crop_bottom, crop_left + 1:width - crop_right, :);

        if ~isempty(alpha)
            cropped_alpha = alpha(crop_top + 1:height - crop_bottom, crop_left + 1:width - crop_right);
        end

        if num_channels == 4
            imwrite(cropped_img, output_path, 'Alpha', cropped_alpha);
        else
            imwrite(cropped_img, output_path);
        end

        fprintf('裁剪成功！\n');
        fprintf('原始尺寸: %d x %d\n', width, height);
        fprintf('裁剪后尺寸: %d x %d\n', new_width, new_height);
        fprintf('保存路径: %s\n', output_path);

    catch ME
        fprintf('错误: %s\n', ME.message);
    end
end