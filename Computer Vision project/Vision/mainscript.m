clear;
warning('off');
prompt = 'Choose an image from 1 to 14 for test\nor type 0 to test new set of images:';
test_picture_number = input(prompt);

images_number = 14;
image_name = 'practice/t%d.jpg';

disp('Synthesizing training images background...');
norm_background = synthesize_background(images_number,image_name);


object_counter = 1;
nan_counter = 1;

%Segment objects, reduce noise and store object properties for each image
disp('Getting training objects data...');
for i = 1 : 14
    
    %For testing purposes withhold one of the images if needed
    if i ~= test_picture_number
    
        name = sprintf('practice/t%d.jpg',i);
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

        se = strel('disk',1);
        bw3 = bwareaopen(bw3,100);

        [rows, cols] = size(bw3);    
        black = zeros(rows, cols);
    
        labim = bwlabel(bw3);

        objects_number = max(max(labim));
        for j = 1 : objects_number;
            obj = labim;
            obj (obj ~= j) = 0;
            obj (obj ~= 0) = 1;

            list{object_counter}=obj;
            mask = double(obj);
            mask = cat(3,mask,mask,mask);
            colour_object = norm_image .* mask;

            [r,g,b] = get_colour_means(image, obj);        
            colours = zeros(1,3);

            colors(1,1) = r;
            colors(1,2) = g;
            colors(1,3) = b;
            colors_list{object_counter} = colors;

            object_counter = object_counter+1;
        end 
    end
end    


%% Create data set

%True classes of each image
%(Objects are classified in order or how much they are worth - 2pounds is
%class 1, 1 pound coin is class 2, etc.
%The 0 class are noise or poorly detected objects and harder cases which we
%remove from the data set later.

tc{1} = [0, 8, 3, 5, 9, 9, 10, 10, 5, 6, 5, 2, 7];
tc{2} = [0, 8, 9, 3, 5, 6, 3, 10, 2, 3, 9, 8, 10, 1, 5, 7, 2, 4];
tc{3} = [0, 0, 8, 6, 3, 5, 2, 6, 10, 6, 0, 8, 10, 1, 4, 2];
tc{4} = [0, 0, 1, 3, 1, 0, 6, 8, 7, 9, 5, 8, 9, 2, 3];
tc{5} = [0, 9, 1, 3, 5, 10, 9, 8, 6, 6, 2, 0, 3, 8];
tc{6} = [0, 9, 8, 1, 0, 3, 5, 2, 10, 6, 7, 4, 5, 6, 5, 2, 7];
tc{7} = [0, 3, 9, 8, 1, 0, 10, 1, 7, 2, 7, 6, 5, 4, 5, 5, 6];
tc{8} = [0, 3, 1, 8, 0, 10, 6, 5, 4, 2, 5, 5, 3, 7, 6];
tc{9} = [0, 0, 3, 1, 5, 0, 9, 5, 2, 5, 0, 8, 3, 1];
tc{10} = [0, 0, 0, 5, 9, 9, 10, 10, 5, 5, 0, 7];
tc{11} = [0, 0, 5, 0, 0, 10, 5, 5, 0, 7];
tc{12} = [0, 3, 4, 5, 0, 1, 5, 9, 0, 6, 5, 6, 2];
tc{13} = [0, 3, 4, 5, 0, 5, 0, 0, 0, 0, 5, 6, 10];
tc{14} = [0, 3, 4, 5, 0, 6, 9, 1, 7, 0, 6, 0, 5, 6];

true_classes = [];
for i = 1 : 14
    if i ~= test_picture_number
        true_classes = horzcat(true_classes,tc{i});
    end
end

cond = true_classes(:) == 0;
list(cond) = [];
colors_list(cond) = [];
true_classes(cond) = [];  
n = length(list);

data = zeros(n,5);
for k = 1 : n 
    data(k,1:4) = getproperties(list{k}); 

    [objectBoundries,L] = bwboundaries(list{k},'noholes');
    objectMeasurements = regionprops(L, list{k}, 'all'); 
    
     data(k,5) = objectMeasurements.FilledArea - objectMeasurements.Area;

     rgb = colors_list{k};
%       data(k,6) = rgb(1);
%       data(k,7) = rgb(2);
%       data(k,8) = rgb(3);
end
    [data_points, features_number] = size(data);
    
data = cat(2,data,true_classes');
cond = data(:,end) == 0;
data(cond,:) = [];


%% Cross-validation

%Hold-out
[Train, Test] = crossvalind('HoldOut', data_points, 0.10);

train_data = data(Train,1:features_number);
train_true = data(Train,features_number+1);

test_data = data(Test,1:features_number);
test_true = data(Test,features_number+1);


 %% Model build
            
[N,F] = size(train_data);
[Means,Invcors,Aprioris] = buildmodel(F,train_data,N,10,train_true);

%% Classification

disp('\nHold-out validation');
% Predict training data.
predictions_train = zeros(1,N);
for i = 1 : N
    test_vec = train_data(i,:);
    class =  classify(test_vec,10,Means,Invcors,F,Aprioris);
    predictions_train(i) = class;
end

disp('Training data accuracy: ');
disp(sum(predictions_train == train_true')/length(train_true'));

% Predict test data.
[N, F] = size(test_data);
predictions_test = zeros(1,N);
for i = 1 : N
    test_vec = test_data(i,:);
    class =  classify(test_vec,10,Means,Invcors,F,Aprioris);
    predictions_test(i) = class;
end            
disp('Test data accuracy: ');
disp(sum(predictions_test == test_true')/length(test_true'));

%% Cross-validation

% K-fold 
indices = crossvalind('Kfold', data_points, 10);
cp = classperf(data(:,end));
for i = 1:10    
    test = (indices == i); train = ~test;
    
    train_data = data(train,1:features_number);
    train_true = data(train,end);

    test_data = data(test,1:features_number);
    test_true = data(test,end);
    
    [N,F] = size(train_data);
    [Means,Invcors,Aprioris] = buildmodel(F,train_data,N,10,train_true);
    
    [N,F] = size(test_data);
    predictions_test_kfold = zeros(1,N);
    for j = 1 : N
        test_vec = test_data(j,:);
        class =  classify(test_vec,10,Means,Invcors,F,Aprioris);
        predictions_test_kfold(j) = class;
    end
    classperf(cp,predictions_test_kfold,test);
end

classifier_accuracy = cp.CorrectRate;
disp('K-fold cross validation accuracy:');
disp(classifier_accuracy);

comparison = cat(1,predictions_test_kfold, test_true');


%% Test on new data

if test_picture_number ~= 0
    
    perform_test;
    
else
    
    classify_new_set;
    
end

