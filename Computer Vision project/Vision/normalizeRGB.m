function [ norm_image ] = normalizeRGB( image )
%Normalizes RGB of an image
%   Detailed explanation goes here
        imageR = image(:,:,1);
        imageG = image(:,:,2);
        imageB = image(:,:,3);
        
        NormalizedRed = imageR./ sqrt(imageR.^2 + imageG.^2 + imageB.^2);
        NormalizedGreen = imageG./sqrt(imageR.^2 + imageG.^2 + imageB.^2);
        NormalizedBlue = imageB./sqrt(imageR.^2 + imageG.^2 + imageB.^2);
        
        norm_image = cat(3,NormalizedRed,NormalizedGreen,NormalizedBlue);

end

