function target_image = transform_image(source_image, H)
    [x, y] = size(source_image);
    img = zeros(x+2, y+2);
    img(2:x+1, 2:y+1) = source_image;
    H_inv = inv(H);
    
    target_image = zeros(x, y);
    
    for xt = 1:x
        for yt = 1:y
            vec = [xt; yt; 1];
            [xs, ys] = corresponding_points_2D(H_inv, vec);
            val = bilinear_interpolate(img, xs, ys);
            target_image(xt, yt) = val;
        end
    end
end