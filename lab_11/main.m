%% Reading Data
clear;
lena = imread('lena.png');
% ensure that the motion blur kernel sums up to 1
motion_blur_kernel = im2double(imread('mb-kernel.png'));
motion_blur_kernel = motion_blur_kernel/(sum(motion_blur_kernel(:)));

%% Define Parameters
qx = [1 -1];
qy = [1; -1];
l_start = 0.01;
l_end = 2.0;
l_step = 0.01;
n_lambdas = length(l_start:l_step:l_end);

%% L2 regularized NBD
sigma_n_vals = [8 8 8 5 10 15];
sigma_b_vals = [0.5 1 1.5 1 1 1];
n_pairs = length(sigma_b_vals);
best_lambdas = zeros(size(sigma_b_vals));
rmse_vals = zeros(n_pairs, n_lambdas);

%% Save Results
for i = 1:n_pairs
        sigma_b = sigma_b_vals(i);
        sigma_n = sigma_n_vals(i);
        [best_l, rmse] = best_lambda(lena, sigma_b, sigma_n, l_start, l_end, l_step, false, "L2");
        best_lambdas(i) = best_l;
        rmse_vals(i, :) = rmse;
        degraded_image = degrade(lena, sigma_b, sigma_n, false);
        fig0 = figure('visible', 'off');
        imshow(degraded_image)
        name = ['Degraded: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n)];
        title(name);
        saveas(fig0, ['L2_degraded_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n)], 'png');
        fig1 = figure('visible', 'off');
        imshow(deblur_L2_freq(degraded_image, sigma_b, best_l, qx, qy, false))
        name = ['Restored: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n), ' \lambda = ', num2str(best_l)];
        title(name);
        saveas(fig1, ['L2_best_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n)], 'png');
        fig2 = figure('visible', 'off');
        plot(l_start:l_step:l_end, rmse);
        grid on;
        name = ['RMSE: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n)];
        title(name);
        xlabel('\lambda');
        ylabel('MSE');
        saveas(fig2, ['L2_rmse_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n)], 'png');
end

%% Best Looking Results
best_looking_lambdas = [0.15, 0.2, 0.45, 0.09, 0.4, 0.9];
for i = 1:n_pairs
        fig = figure('visible', 'off');
        imshow(deblur_L2_freq(degrade(lena, sigma_b_vals(i), sigma_n_vals(i), false) , sigma_b_vals(i), best_looking_lambdas(i), qx, qy, false));
        name = ['Best Looking: \sigma_{b} = ', num2str(sigma_b_vals(i)), ' \sigma_{n} = ', num2str(sigma_n_vals(i)), ' \lambda = ', num2str(best_looking_lambdas(i))];
        title(name);
        saveas(fig, ['L2_best_looking_img_sigma_b_', num2str(10*sigma_b_vals(i)), '_sigma_n_', num2str(sigma_n_vals(i))], 'png');
end

%% L2 vs L1 Regularization
sigma_b = 1.5;
sigma_n_vals = [1, 5, 5];
n_pairs = length(sigma_n_vals);
degraded_1 = degrade(lena, sigma_b, sigma_n_vals(1), false);
degraded_5 = degrade(lena, sigma_b, sigma_n_vals(2), false);
degraded_mb = degrade(lena, motion_blur_kernel, sigma_n_vals(3), true);

fig = figure('visible', 'off');
imshow(degraded_1);
name = ['Degraded: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(1))];
title(name);
saveas(fig, ['L0_degraded_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(1))], 'png');

fig = figure('visible', 'off');
imshow(degraded_5);
name = ['Degraded: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(2))];
title(name);
saveas(fig, ['L0_degraded_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(2))], 'png');

fig = figure('visible', 'off');
imshow(degraded_mb);
name = ['Degraded: Motion Blur \sigma_{n} = ', num2str(sigma_n_vals(3))];
title(name);
saveas(fig, ['L0_degraded_motion_blur_sigma_n_', num2str(sigma_n_vals(3))], 'png');

%% Best Looking Results for L1
fig = figure('visible', 'off');
imshow(deblur_L1(degraded_1, sigma_b, 0.0001, false));
name = ['Best Looking: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(1)), ' \lambda = ', num2str(0.0001)];
title(name);
saveas(fig, ['L1_best_looking_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(1))], 'png');

fig = figure('visible', 'off');
imshow(deblur_L1(degraded_5, sigma_b, 0.003, false));
name = ['Best Looking: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(2)), ' \lambda = ', num2str(0.003)];
title(name);
saveas(fig, ['L1_best_looking_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(2))], 'png');
        
fig = figure('visible', 'off');
imshow(deblur_L1(degraded_mb, motion_blur_kernel, 0.002, true));
name = ['Best Looking: Motion Blur \sigma_{n} = ', num2str(sigma_n_vals(3)), ' \lambda = ', num2str(0.002)];
title(name);
saveas(fig, ['L1_best_looking_img_motion_blur_sigma_n_', num2str(sigma_n_vals(3))], 'png');
     
%% Best Looking Results for L2
fig = figure('visible', 'off');
imshow(deblur_L2_freq(degraded_1, sigma_b, 0.005, qx, qy, false));
name = ['Best Looking: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(1)), ' \lambda = ', num2str(0.005)];
title(name);
saveas(fig, ['L2_best_looking_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(1))], 'png');

fig = figure('visible', 'off');
imshow(deblur_L2_freq(degraded_5, sigma_b, 0.2, qx, qy, false));
name = ['Best Looking: \sigma_{b} = ', num2str(sigma_b), ' \sigma_{n} = ', num2str(sigma_n_vals(2)), ' \lambda = ', num2str(0.2)];
title(name);
saveas(fig, ['L2_best_looking_img_sigma_b_', num2str(10*sigma_b), '_sigma_n_', num2str(sigma_n_vals(2))], 'png');
        
fig = figure('visible', 'off');
imshow(deblur_L2_freq(degraded_mb, motion_blur_kernel, 0.07, qx, qy, true));
name = ['Best Looking: Motion Blur \sigma_{n} = ', num2str(sigma_n_vals(3)), ' \lambda = ', num2str(0.07)];
title(name);
saveas(fig, ['L2_best_looking_img_motion_blur_sigma_n_', num2str(sigma_n_vals(3))], 'png');