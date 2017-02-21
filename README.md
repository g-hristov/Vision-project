# Vision-project
Computer vision project using MATLAB to identify different coins using machine learning.

The project takes the pictures in the training set, and using a median value for all pixels across all images synthesizes a background.
The background is then subtracted leaving only the objects. 
Using machine learning with a few specially chosen features the application can predict a new image.

On start up choosing one of the images means all the rest are used for training and the test image is only used for test predicting.

Due to the small training set only a few feaures were chosen, however with a larger training set, more features can be added (such as color) to increase prediction accuracy.
