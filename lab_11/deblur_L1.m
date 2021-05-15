function clean_image = deblur_L1(g, blur_param, lambda, is_motion_blur)
        if ~ is_motion_blur
                h = gaussian_kernel(blur_param);
                clean_image = admmfft(g, h, lambda, 1);
        else
                clean_image = admmfft(g, blur_param, lambda, 1);
        end
end