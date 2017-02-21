function [ background ] = synthesize_background( images_number, image_name)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

red = zeros(480,640,images_number);
green = zeros(480,640,images_number);
blue = zeros(480,640,images_number);

for i = 1 : images_number

            name = sprintf(image_name,i);
            image = imread(name);

            image = double(image);

            for r = 1 : 480
                for c = 1 : 640
                    red(r,c,i) = image(r,c,1);
                    green(r,c,i) = image(r,c,2);
                    blue(r,c,i) = image(r,c,3);
                end
            end
end
        
bgR = median(red,3);
bgG = median(green,3);
bgB = median(blue,3);


%Form and normalize background RGB
norm_background = cat(3, bgR, bgG, bgB);
norm_background = normalizeRGB(norm_background);

%Filter  background to remove any leftover noise
new_bgR = medfilt2(norm_background(:,:,1), [18 18]);
new_bgG = medfilt2(norm_background(:,:,2), [18 18]);
new_bgB = medfilt2(norm_background(:,:,3), [18 18]);

background = cat(3,new_bgR,new_bgG,new_bgB);
