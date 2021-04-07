function [feat_disease]=featureselection(im)  %% the function is defined 
img=im;
seg_img=im;
img=rgb2gray(img); %% the image is converted to gray scale
glcms = graycomatrix(img);% Create the Gray Level Cooccurance Matrices (GLCMs)
%Evaluate 13 features from the disease affected region only
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');  %% the function is applied to extract features from the gray level matrix 
Contrast = stats.Contrast;  %% the stats is the structed array
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put the 13 features in an array
feat_disease = [Contrast,Correlation,Energy,Homogeneity];

end