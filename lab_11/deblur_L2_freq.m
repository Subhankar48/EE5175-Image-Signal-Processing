function clean_img = deblur_L2_freq(g, blur_param, lambda, qx, qy, is_motion_blur)
        [x, y] = size(g);
        if ~ is_motion_blur
                h = gaussian_kernel(blur_param);
                H = psf2otf(h, [x y]);
        else
                H = psf2otf(blur_param, [x y]);
        end
%         get the matrices as defined in the assignment PDF
        Qx = psf2otf(qx, [x y]);
        Qy = psf2otf(qy, [x y]);
%         calculate the 2D DFT
        G = fft2(g);
%         Formula as derived
        freq_trans = conj(H)./(abs(H).^2+lambda*(abs(Qx).^2)+lambda*(abs(Qy).^2));
%         Calculate the 2D IDFT
        clean_img = abs(ifft2(freq_trans.*G));
end