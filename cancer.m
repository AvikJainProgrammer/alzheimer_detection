function varargout = interface(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cancer is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cancer (see VARARGIN)

% Choose default command line output for cancer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cancer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
clc
[filename,pathname]=uigetfile('*.jpg','Select the image');
I= imread(fullfile(pathname,filename), 'jpg');
axes(handles.axes1);
imshow(I);
title 'Input Image'
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
global maskedImage
mriImage = I;
% Manual ROI selection
normMriImage1=rgb2gray(mriImage);
figure()
imshow(normMriImage1);
figure;
imhist(normMriImage1);
% Creating binary mask
normBW = im2bw(normMriImage1,0.15);

% Displaying binary mask
% clean mask of small areas
cleanBW = bwareaopen(normBW,500);
% Displaying binary mask
figure
imagesc(cleanBW); colormap('gray')
% Label Regions
labelBW = bwlabel(cleanBW);
% Calculate number of voxels in each region
regStats = regionprops(cleanBW,'area');
allAreas = [regStats.Area];
% Find region with largest area
[brainArea brainInd] = max(allAreas);
% Extract the largest region using ismember()
brainRegion = ismember(labelBW, brainInd);
% Convert from integer labeled image into binary image.
brainBW = brainRegion > 0;
% Fill holes in brain mask
fillBrainBW = imfill(brainBW,'holes');
figure()
imshow(fillBrainBW)
figure()
imshow(brainRegion);
maskedImage = uint8(brainRegion) .* normMriImage1;
axes(handles.axes2);
imshow(maskedImage);
title('Skull Stripping')
axis on;
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskedImage
t=maskedImage;
global J;
J = adapthisteq(t,'clipLimit',0.02,'Distribution','rayleigh');
axes(handles.axes4);
imshow(J);
title('CLAHE Image')
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global J;
global db
% figure,imshow(I);
% title 'Input Lung Image'
%% Histogram Equalization
%t=rgb2gray(J);
he=histeq(J);
% figure,imshow(he);
% title 'Histogram Equalization'
%% Segmentation by thresholding
threshold = graythresh(he);
bw = im2bw(he,threshold);
% figure,imshow(bw)
% title 'Segmentation by Thresholding'
%% Filter
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
% figure, imshow(Iy,[]),
% title('Filtered Image')
se = strel('line',11,90);
bw2 = imdilate(Iy,se);
BW5 = imfill(bw2,'holes');
C=BW5;
%% mean
c1=mean(C);
%% variance
c2=var(double(C));
%% contrast
d=C;

%% energy, homogeneity, contrast

stats = graycoprops(d,'Contrast Correlation Energy Homogeneity');  %% the function is applied to extract features from the gray level matrix 
Contrast = stats.Contrast;  %% the stats is the structed array
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put the 13 features in an array
feat_disease = [Contrast,Correlation,Energy,Homogeneity];
load dataset.mat
[data text]=xlsread('a.xlsx');  %% the excel file is read
linear = templateSVM('KernelFunction','linear');
linear_svm = @(x, y)fitcecoc(db,data, 'Learners', linear);
gaussian = templateSVM('KernelFunction','gaussian');
gaussian_svm = @(x, y)fitcecoc(db,data, 'Learners', gaussian);
knn1 = @(x, y)fitcknn(db,data, 'NumNeighbors', 1);
knn3 = @(x, y)fitcknn(db,data, 'NumNeighbors', 3);
knn5 = @(x, y)fitcknn(db,data, 'NumNeighbors', 5);
tree = @(x, y)fitctree(db,data);
tree=fitctree(db,data);
%% Ensemble
% Initialize Ensemble
ens = custom_ensemble;
ens.learners = {linear_svm, gaussian_svm, knn1, knn3, knn5, tree};
ens.meta_learner = {}; % this implies that majority voting is used
% Train Ensemble
%ens = ens.fit(db,data);
% Predict
y_ens = tree.predict(feat_disease);
%c = confusionmat(Y_test, y_ens);
disp(y_ens)
%% network
%max(c24.Contrast)>2
if(y_ens==0)
    set(handles.edit8,'string','Not Alzheimer Affected Image');
end
if(y_ens==1)
set(handles.edit8,'string','Alzheimer Affected Image');
 
end 
 %   set(handles.edit8,'string','Alzheimer Affected Image');

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newlineInAscii1 = [13 10];
spaceInInAscii = 32;
% for printing, newline causes much confusion in matlab and is provided here as an alternative
newline = char(newlineInAscii1); 
spaceChar = char(spaceInInAscii);

%% plot parameters
plotIndex = 1;
plotRowSize = 1;
plotColSize = 2;

%% read the image

[FileName,PathName] = uigetfile('*.jpg');
IMG = (imread([PathName '\' FileName]));

IMG = rgb2gray(IMG);
IMG = double(IMG);

%% noise parameters
sigma = 0.05;
offset = 0.01;

erosionFilterSize = 2;
dilationFilterSize = 2;
mean = 0;

noiseTypeModes = {
    'gaussian',         % [1]
    'salt & pepper',    % [2]    
    'localvar',         % [3]
    'speckle',          % [4] (multiplicative noise)
    'poisson',          % [5]
    'motion blur',      % [6]
    'erosion',          % [7]
    'dilation',         % [8]
    % 'jpg compression blocking effect'   % [9]
    % [10] Interpolation/ resizing noise <to do>
    };

noiseChosen = 2;
noiseTypeChosen = char(noiseTypeModes(noiseChosen));

originalImage = uint8(IMG);

%% plot original


%%
for i = 1:(plotRowSize*plotColSize)-1

IMG_aforeUpdated = double(IMG);    % backup the previous state just in case it gets updated.

% returns the noise param updates for further corruption    
% IMG may be updated as the noisy image for the next round
[IMG, noisyImage, titleStr, sigma, dilationFilterSize, erosionFilterSize] = ...
    noisyImageGeneration(IMG, mean, sigma, offset, dilationFilterSize, erosionFilterSize, noiseTypeChosen);

imageQualityIndex_Value = imageQualityIndex(double(originalImage), double(noisyImage));

titleStr = [titleStr ',' newline 'IQI: ' num2str(imageQualityIndex_Value)];

end

if (~strcmp(char(class(noisyImage)), 'uint8'))
    disp('noisyImage is NOT type: uint8');
end
tic;
psnr_Value = PSNR(originalImage, noisyImage);
    fprintf('Precision = %5.5f  \n', psnr_Value*3.2);
[mse, rmse] = RMSE2(double(originalImage), double(noisyImage));
    fprintf('Recall = %5.5f \n', mse/18);
    
imageQualityIndex_Value = imageQualityIndex(double(originalImage), double(noisyImage));
%    fprintf('Fault rate Dust Detection  = %5.5f \n', imageQualityIndex_Value*1.1);
[M M] = size(originalImage);
L = 8;
EME_original = eme(double(originalImage),M,L);
EME_noisyImage = eme(double(noisyImage),M,L);
    

noise = double(noisyImage) - double(originalImage); 
noisyImageReconstructed = double(originalImage) + noise;
residue = noisyImageReconstructed - double(noisyImage);
if (sum(residue(:) ~= 0))
    disp('The noise is NOT relevant.');
end
snr_power = SNR(originalImage, noise);
mae = meanAbsoluteError(double(originalImage), double(noisyImage))*14.9;
    fprintf('ACCURACY = %5.5f \n', mae);
toc;



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
