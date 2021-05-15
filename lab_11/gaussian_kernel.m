function kernel = gaussian_kernel(sigma)
        w = kernel_size(sigma);
        d = ceil(w/2);
        if d == 0
                kernel = ones(w, w);
        else
                [x, y] = meshgrid(1:w, 1:w);
                exponent = -((x-d).^2 + (y-d).^2)/(2*sigma^2);
                kernel = exp(exponent);
                kernel = kernel/sum(kernel(:));
        end
end