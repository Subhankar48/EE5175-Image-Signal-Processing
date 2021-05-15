function [intensity_val, within_canvas] = bilinear_interpolate_modified(zero_padded_source_image, x, y)
    % shape of the zero padded image
    [dx, dy] = size(zero_padded_source_image);
    % get the shape of the original image
    dx = dx-2; 
    dy = dy-2;
    % +1 as we are taking coordinates with respect to a zero padded image
    x = x+1;
    y = y+1;

    % x', y', a, b as defined in the lecture
    x_prime = floor(x);
    y_prime = floor(y);
    a = x-x_prime;
    b = y-y_prime;

    if x_prime >= 1 && x_prime <= dx+1 && y_prime >= 1 && y_prime <= dy+1
        % intensity value using bilinear interpolation
        intensity_val = (1-a)*(1-b)*zero_padded_source_image(x_prime, y_prime) ...
            + (1-a)*b*zero_padded_source_image(x_prime, y_prime+1) ...
            + a*(1-b)*zero_padded_source_image(x_prime+1, y_prime) ...
            + a*b*zero_padded_source_image(x_prime+1, y_prime+1);
        % If the requested (xs, ys) lies within the source image canvas
        % set within_canvas = 1
        within_canvas = 1;
    else
        % If the (xs, ys) does not exist in the source image, assign 0
        % for the corresponding (xt, yt) in the target image and set
        % within_canvas = 0
        intensity_val = 0;
        within_canvas = 0;
    end

end