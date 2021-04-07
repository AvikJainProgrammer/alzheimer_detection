[fname path]=uigetfile('.jpg','Give the testing file as input');  %The uiget file is the function to read image dynamically 
fname=strcat(path,fname);  %% the path and image name get concadinated 
im=imread(fname);  %% imread function is applied to read the image 
imshow(im);  %% the imshow function is applied to applied to show the image 
[feat_disease]=featureselection(im);  %% the feature selection function is applied to extract features of the input image 
try  %% the try statement is executed when new database is created 
load dataset.mat;  %% the mat file is read to save features into the database 
F=[feat_disease];  %% the extracted features are put into the F variabale 
db=[db;F];  %% the extracted features are exchanged with the db varibale 
save dataset.mat db  %% the features are saved into the mat file 
catch  %% the catch statement is executed when database is already created 
F=[feat_disease]; %% the features are put into the F varibale 
db=F;  %% the features are exchanged with the db varibale 
save dataset.mat db  %% the features are saved into the database
end
