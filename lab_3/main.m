%% Read images
clear;
im1 = imread('img1.png');
im2 = imread('img2.png');
im3 = imread('img3.png');

%% RANSAC Parameters - stricter conditions used than mentioned 
epsilon = 5;
fraction = 0.9;
% n_iters  = 10^8 is never used. It converges almost always in the first
% attempt or at worst, within the first 4-5 attempts
n_iters = 10^8;
n_samples = 4;

%% H21 Matrix
% Get sift correspondences and compute the homography
[corresp1, corresp2] = sift_corresp('img1.png','img2.png');
H21 = ransac_self(corresp2, corresp1, epsilon, fraction, n_samples, n_iters);

%% H23 Matrix
[corresp2, corresp3] = sift_corresp('img2.png','img3.png');
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
% This canvas size is very liberal. Can do with much smaller canvases
canvas = zeros(n_canvas_rows, n_canvas_columns);

%% Offset
offset_row = ceil(n_canvas_rows/3);
offset_column = ceil(n_canvas_columns/3);

%% Stitch Images
% Use the pseudo code as given in the assignment PDF
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
        
        % Average only those values which fall within the corresponding 
        % image bounds
        % Checking for n_in_range>1 and not n_in_range>=1 as the case when
        % we have n_in_range==1, division by 1 is just an extra
        % computationally unnecessary step
        if n_in_range>1
            val = val/n_in_range;
        end
        
        canvas(x_canvas, y_canvas) = val;
    end
end

%% Display the image
% After all the operations, canvas is a float value. If we show it
% directly, we will get a saturated image as MATLAB interprets it as an
% image with datatype float and assumes values >= 1 are saturated pixels
canvas = uint8(canvas);
% The numbers below have been fixed heuristically 
% by looking at the final image
canvas = canvas(260:860, 350:1750);
imshow(canvas)
title("Images stitched together");

