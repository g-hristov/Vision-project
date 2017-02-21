
prompt = 'Number of images: ';
images_number = input(prompt);

prompt = 'Image names: ';
image_name = input(prompt,'s');

%Create background
norm_background = synthesize_background(images_number,image_name);
object_counter = 1;

objects_per_image = zeros(1,images_number);

%Segment objects, reduce noise and store object properties
for i = 1 : images_number
    
    name = sprintf(image_name,i);
    image = imread(name);

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
    objects_per_image(i) = objects_number;
    
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
for j = 1 : N
    test_vec = new_test_data(j,:);
    class =  classify(test_vec,10,Means,Invcors,F,Aprioris);
    predictions_test(j) = class;
end


%% Display image and assigned classes

while 1 == 1

prompt = 'Choose which image you would like to review\ntype 0 to break: ';
disp_image_number = input(prompt);

if disp_image_number == 0
    break;
end


%Retrieve the objects indexes of that image
objects_number = objects_per_image(disp_image_number);
objects_before = objects_per_image(1:disp_image_number-1);
objects_before = sum(objects_before);
objects_after = objects_per_image(disp_image_number+1:end);
objects_after = sum(objects_after);


name = sprintf(image_name,disp_image_number);
I = imread(name);

figure; imshow(I);
hold on;

for j = objects_before+1 : objects_before + objects_number
    stats = regionprops(objects_list{j},'all');
    pos = stats.BoundingBox;
    
     if predictions_test(j) == 1
        text = '2.00';
    end
    if predictions_test(j) == 2
        text = '1.00';
    end
    if predictions_test(j) == 3
        text = '0.75';
    end
    if predictions_test(j) == 4
        text = '0.50';
    end
    if predictions_test(j) == 5
        text = '0.25';
    end
    if predictions_test(j) == 6
        text = '0.20';
    end
    if predictions_test(j) == 7
        text = '0.05';
    end
    if predictions_test(j) == 8
        text = '0.02';
    end
    if predictions_test(j) == 9
        text = '0.00';
    end
    if predictions_test(j) == 10
        text = '0.00';
    end
    
    an=annotation('textbox','String',text);
    set(an,'parent',gca);
    set(an,'position',pos);
end
disp('Predicted classes:');
disp(predictions_test(objects_before+1 : objects_before + objects_number));
end