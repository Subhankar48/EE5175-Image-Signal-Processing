function k_size = kernel_size(sigma)
        k_size = ceil(6*sigma);
        if mod(k_size, 2) == 0
                k_size = k_size+1;
        end
end