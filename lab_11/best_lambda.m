function [lambda_best, rmse_vals] = best_lambda(image, blur_param, sigma_n, start_lambda, stop_lambda, step_size, is_motion_blur, reg)
        [x, y] = size(image);
        if ~is_motion_blur
                h = gaussian_kernel(blur_param);
                H = psf2otf(h, [x y]);
        else
                H = psf2otf(blur_param, [x y]);
        end
        qx = [1 -1];
        qy = [1; -1];
        Qx = psf2otf(qx, [x y]);
        Qy = psf2otf(qy, [x y]);
        degraded_image = degrade(image, blur_param, sigma_n, is_motion_blur);
        lambda_vals = start_lambda:step_size:stop_lambda;
        n_lambda_vals = length(lambda_vals);
        rmse_vals = zeros(size(lambda_vals));
        lambda_best = start_lambda;
        rmse_best = Inf;
        if reg == "L1"
                wait_bar = waitbar(0, ["Finding best lambda with L1 norm regularization..."]);
                for i = 1:n_lambda_vals
                        lambda = lambda_vals(i);
                        clean_image = admmfft(degraded_image, h, lambda, 1);
                        rmse = immse(clean_image, degraded_image);
                        rmse_vals(i) = rmse;
                        if rmse < rmse_best
                                rmse_best = rmse;
                                lambda_best = lambda;
                        end
                        waitbar(i/n_lambda_vals);
                end
                close(wait_bar);
        elseif reg == "L2"
                wait_bar = waitbar(0, "Finding best lambda with L2 norm regularization...");
                for i = 1:n_lambda_vals
                        lambda = lambda_vals(i);
                        G = fft2(degraded_image);
                        freq_trans = conj(H)./(abs(H).^2+lambda*(abs(Qx).^2)+lambda*(abs(Qy).^2));
                        clean_image = abs(ifft2(freq_trans.*G));
                        rmse = immse(clean_image, degraded_image);
                        rmse_vals(i) = rmse;
                        if rmse < rmse_best
                                rmse_best = rmse;
                                lambda_best = lambda;
                        end
                        waitbar(i/n_lambda_vals);
                end
                close(wait_bar);
        end
end