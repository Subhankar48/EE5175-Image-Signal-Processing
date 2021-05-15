function noisy_image = gaussian_noise(image, sigma)
        noisy_image = imnoise(image, 'gaussian', 0,  sigma^2);
end