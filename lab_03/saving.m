function saving(imname, savename)
    img = imread(imname);
    img = rgb2gray(img);
    [~, y] = size(img);
    s = 0.99*1000/y;
    img = imresize(img, s);
    imwrite(img, savename);
end
