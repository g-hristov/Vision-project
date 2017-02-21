function [ r, g, b ] = get_colour_means( pic, obj )
     pic = double(pic);
     norm_image = normalizeRGB(pic);
   
    mask = double(obj);
    mask = cat(3,mask,mask,mask);
    
    cob = norm_image .* mask;
    
    rchan = cob(:,:,1);
    gchan = cob(:,:,2);
    bchan = cob(:,:,3);
    
    mask = double(obj);
    
    stats = regionprops(mask, 'PixelIdxList');
    p = stats.PixelIdxList;
    [n, m] = size(p);
    
    r = mean(rchan(p));
    g = mean(gchan(p));
    b = mean(bchan(p));
    
    if isnan(r) | isnan(g) | isnan(b)
        
        cob(find(isnan(cob))) = 0;
        rchan = cob(:,:,1);
        gchan = cob(:,:,2);
        bchan = cob(:,:,3);
        mask = double(obj);
        stats = regionprops(mask, 'PixelIdxList');
        p = stats.PixelIdxList;
        [n, m] = size(p);
        r = mean(rchan(p));
        g = mean(gchan(p));
        b = mean(bchan(p));
        
    end
    

end