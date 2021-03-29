%% Read images
% Comments skipped as it will be exactly the same as those in main.m
clear;
im1 = imread('g1.png');
im2 = imread('g2.png');
im3 = imread('g3.png');

%% RANSAC Parameters
epsilon = 5;
fraction = 0.9;
n_iters = 10^8;
n_samples = 4;

%% H21 Matrix
[corresp2, corresp1] = sift_corresp('g2.png','g1.png');
H21 = ransac_self(corresp2, corresp1, epsilon, fraction, n_samples, n_iters);

%% H23 Matrix
[corresp2, corresp3] = sift_corresp('g2.png','g3.png');
H23 = ransac_self(corresp2, corresp3, epsilon, fraction, n_samples, n_iters);

%% Image sizes
[x1, y1] = size(im1);
[x2, y2] = size(im2);
[x3, y3] = size(im3);
% x1=x2=x3 and y1=y2=y3
x = x1;
y = y1;

%% Zero pad images for Bilinear Interpolation
temp = zeros(x1+2, y1+2);
temp(2:x1+1, 2:y1+1) = im1;
im1 = temp;
temp = zeros(x2+2, y2+2);
temp(2:x2+1, 2:y2+1) = im2;
im2 = temp;
temp = zeros(x3+2, y3+2);
temp(2:x3+1, 2:y3+1) = im3;
im3 = temp;
clear temp;

%% Build canvas
n_canvas_rows = x1+x2+x3;
n_canvas_columns = y1+y2+y3;
canvas = zeros(n_canvas_rows, n_canvas_columns);

%% Offset
offset_row = ceil(n_canvas_rows/3);
offset_column = ceil(n_canvas_columns/3);

%% Stitch Images

for x_canvas = 1:n_canvas_rows
    for y_canvas = 1:n_canvas_columns
        
        xt = x_canvas - offset_row;
        yt = y_canvas - offset_column;
        
        vec = [xt; yt; 1];
        [xs1, ys1] = corresponding_points_2D(H21, vec);
        [xs3, ys3] = corresponding_points_2D(H23, vec);
        
        [val1, in_range1] = bilinear_interpolate_modified(im1, xs1, ys1);
        [val3, in_range3] = bilinear_interpolate_modified(im3, xs3, ys3);
        [val2, in_range2] = bilinear_interpolate_modified(im2, xt, yt);
        
        n_in_range = in_range1+in_range2+in_range3;
        
        val = 0;
        
        if in_range1>0
            val = val+val1;
        end
        
        if in_range2>0
            val = val+val2;
        end
        
        if in_range3>0
            val = val+val3;
        end
        
        if n_in_range>1
            val = val/n_in_range;
        end
        
        canvas(x_canvas, y_canvas) = val;
    end
end

%% Display the image
canvas = uint8(canvas);
% The numbers below have been fixed heuristically 
% by looking at the final image
canvas = canvas(510:1650, 486:2320);
imshow(canvas)
title("Images stitched together");

