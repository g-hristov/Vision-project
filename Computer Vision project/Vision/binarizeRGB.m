function [ bw ] = binarizeRGB( image )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

redChannel = image(:, :, 1);
greenChannel = image(:, :, 2);  
blueChannel = image(:, :, 3);

% imshow(blueChannel); figure;

[n, m] = size(redChannel);
redmean = 0;
for i = 1:n
    for j = 1:m
        redmean = redmean + (redChannel(i,j) / (n*m));
    end
end
redsd = 0;
for i = 1:n
    for j = 1:m
        redsd = redsd + (((redChannel(i,j) - redmean)*(redChannel(i,j) - redmean)) / (n*m));
    end
end
redsd = sqrt(redsd);

bwred = double(abs(redChannel - redmean) > 1*redsd);
%imshow(bwred);

greenmean = 0;
for i = 1:n
    for j = 1:m
        greenmean = greenmean + (greenChannel(i,j) / (n*m));
    end
end
greensd = 0;
for i = 1:n
    for j = 1:m
        greensd = greensd + (((greenChannel(i,j) - greenmean)*(greenChannel(i,j) - greenmean)) / (n*m));
    end
end
greensd = sqrt(greensd);

bwgreen = double(abs(greenChannel - greenmean) > 2*greensd);
%imshow(bwgreen);

bluemean = 0;
for i = 1:n
    for j = 1:m
        bluemean = bluemean + (blueChannel(i,j) / (n*m));
    end
end
bluesd = 0;
for i = 1:n
    for j = 1:m
        bluesd = bluesd + (((blueChannel(i,j) - bluemean)*(blueChannel(i,j) - bluemean)) / (n*m));
    end
end
bluesd = sqrt(bluesd);

bwblue = double(abs(blueChannel - bluemean) > 1*bluesd);
%imshow(bwblue);

bw = bwred + bwgreen + bwblue;

end

