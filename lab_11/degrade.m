function degraded_image = degrade(image, blur_param, sigma_n, is_motion_blur)
%         fix the seed
        rng(1);
%         convert the image to [0,1] range
        image = im2double(image);
%         convert noise std in the appropriate range
        sigma_n = sigma_n/255;
        if ~is_motion_blur
                blur_kernel = gaussian_kernel(blur_param);
                blurred_image = conv2(image, blur_kernel, 'same');
%                 add noise
                degraded_image = gaussian_noise(blurred_image, sigma_n);
        else
                blurred_image = conv2(image, blur_param, 'same');
%                 add noise
                degraded_image = gaussian_noise(blurred_image, sigma_n);
        end
end