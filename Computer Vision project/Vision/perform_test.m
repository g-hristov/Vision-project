
%   Script for testing on one of the training images

image_name = sprintf('practice/t%d.jpg',test_picture_number);
image = imread(image_name);

object_counter = 1;

image = double(image);

norm_image = normalizeRGB(image);

norm_image_cont = imadjust(norm_image,stretchlim(norm_image));
norm_background_cont = imadjust(norm_background,stretchlim(norm_image));

objects = norm_image_cont - norm_background_cont;

bw = binarizeRGB(objects);

se = strel('disk',1);
bw2 = bwareaopen(bw,30);

bw3 = bwmorph(bw2,'bridge',1);

bw3 = bwmorph(bw3,'erode',.5);   

bw3 = bwareaopen(bw3,100);

labim = bwlabel(bw3);

objects_number = max(max(labim));

for j = 1 : objects_number;
    obj = labim;
    obj (obj ~= j) = 0;
    obj (obj ~= 0) = 1;

    objects_list{object_counter}=obj;
    mask = double(obj);
    mask = cat(3,mask,mask,mask);
    colour_object = norm_image .* mask;

    [r,g,b] = get_colour_means(image, obj);        
    colours = zeros(1,3);

    colors(1,1) = r;
    colors(1,2) = g;
    colors(1,3) = b;
    test_colors_list{object_counter} = colors;

    object_counter = object_counter+1;
end 


%% Create data set

n = length(objects_list);

new_test_data = zeros(n,5);
for k = 1 : n 
    new_test_data(k,1:4) = getproperties(objects_list{k}); 

    [objectBoundries,L] = bwboundaries(objects_list{k},'noholes');
    objectMeasurements = regionprops(L, objects_list{k}, 'all'); 
    
     new_test_data(k,5) = objectMeasurements.FilledArea - objectMeasurements.Area;
           
     rgb = test_colors_list{k};
%       new_test_data(k,6) = rgb(1);
%       new_test_data(k,7) = rgb(2);
%       new_test_data(k,8) = rgb(3);
end
    [data_points, features_number] = size(new_test_data);
    
%% Classification

X_train = data(:,1:features_number);
true_classes = data(:,end);

[N,F] = size(X_train);
[Means,Invcors,Aprioris] = buildmodel(F,X_train,N,10,true_classes);

[N, F] = size(new_test_data);
predictions_test = zeros(1,N);
for i = 1 : N
    test_vec = new_test_data(i,:);
    class =  classify(test_vec,10,Means,Invcors,F,Aprioris);
    predictions_test(i) = class;
end

%% Display image and assigned classes

I = uint8(image);
figure; imshow(I);
hold on;
for i = 1 : N
    stats = regionprops(objects_list{i},'all');
    pos = stats.BoundingBox;
    hold on;
    text = sprintf('%d',predictions_test(i));
    
    if predictions_test(i) == 1
        text = '2.00';
    end
    if predictions_test(i) == 2
        text = '1.00';
    end
    if predictions_test(i) == 3
        text = '0.75';
    end
    if predictions_test(i) == 4
        text = '0.50';
    end
    if predictions_test(i) == 5
        text = '0.25';
    end
    if predictions_test(i) == 6
        text = '0.20';
    end
    if predictions_test(i) == 7
        text = '0.05';
    end
    if predictions_test(i) == 8
        text = '0.02';
    end
    if predictions_test(i) == 9
        text = '0.00';
    end
    if predictions_test(i) == 10
        text = '0.00';
    end
    
    an=annotation('textbox','String',text);
    set(an,'parent',gca);
    set(an,'position',pos);
    hold on;
end
hold on;

disp('Predicted classes:');
disp(predictions_test);

% end
