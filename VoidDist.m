clc; clear; close all;

% Choose the work directory
folder_REF = uigetdir('start_path', 'Choose the work directory (data)');
cd(folder_REF);

% User inputs
pix = 0.0167;                                                               % This can be calculated from the lead marker or any other object with known length in the images

% Read the reference image for ROI selection
im_pack = imread('Fixed.tif');                                              % This is the reference image. Change it as needed
im_pack = im2double(im_pack);

% Select the first reference rectangle (packed solid)
figure, imshow(im_pack);
title('Select the reference rectangle for packed solid (minimum voidage)');
rect_pack = round(getrect);
ROI_p = imcrop(im_pack, rect_pack);
ROI_p = im2double(ROI_p);
eps_pack = 0.38;                                                            % Voidage for packed solid. Can be calculated by considering the bulk density of the sand within the reactor

% Select the second reference rectangle (freeboard)
title('Select the reference rectangle for freeboard (maximum voidage)');
rect_fb = round(getrect);
ROI_fb = imcrop(im_pack, rect_fb);
ROI_fb = im2double(ROI_fb);
eps_fb = 0.999;                                                             % Voidage for the freeboard of the reactor

% Close the figure
close;

% Ensure ROI_p and ROI_fb have the same size
min_rows = min(size(ROI_p, 1), size(ROI_fb, 1));
min_cols = min(size(ROI_p, 2), size(ROI_fb, 2));
ROI_p = ROI_p(1:min_rows, 1:min_cols);
ROI_fb = ROI_fb(1:min_rows, 1:min_cols);

% Calculate intensity ratios and constants
ek = (1 - eps_pack) / (1 - eps_fb);
numk = (ROI_p - ek * ROI_fb);
denk = 1 - ek;
I01 = mean(numk(:) / denk);
I0 = mean([I01 max(ROI_fb(:))]);
num_ = I0 - ROI_p;                                                          % Packed solid
den_ = I0 * (1 - eps_pack);
const0 = mean(num_ ./ den_);
const = mean(const0);
EC_pack = 1 - (I0 - ROI_p) ./ (I0 * const);
E_calc_pack = mean(EC_pack(:));
EC_bubble = 1 - (I0 - ROI_fb) ./ (I0 * const);
E_calc_bubble = mean(EC_bubble(:));
m = (E_calc_bubble - E_calc_pack) / (eps_fb - eps_pack);
q = eps_pack - m * E_calc_pack;

% Select the region of interest (ROI) for further operations
figure, imshow(im_pack);
title('Select the region of interest for voidage distribution calculation');
rect_roi = round(getrect);
close;

% Loop for calculating the voidage in all frames within the selected ROI
cont = 0;
frame_i = 220; % Initial frame
frame_f = 260; % Final frame
n_frames = frame_f - frame_i + 1;
for j = frame_i:frame_f
    filename = sprintf('File%08d.tif', j);                                  % File name (change it according to the name of your file, %08d means how many digits are in your file name. In this case is 8 digits)
    Img = imread(filename);
    Img = im2double(Img);
    
    % Crop the image to the selected ROI
    Img_roi = imcrop(Img, rect_roi);
    
    % Calculate the voidage within the selected ROI
    epsilon_in = 1 - (I0 - Img_roi) ./ (I0 * const);
    epsilon = m * epsilon_in + q;
    cont = cont + 1;
    Eps_matrix(:, :, cont) = epsilon;
    eps_av_dy = mean(epsilon, 2);
    E_dy(:, cont) = eps_av_dy;
end

% Time-average voidage distribution
voidage_average = mean(Eps_matrix, 3);

% Time array
tspan = 1/36;                                                               % Frame per second of the X-ray facility
t = 0:tspan:(n_frames - 1)*tspan;                                           % Time
x = (0:size(epsilon, 2))*pix;                                               % Reactor radius
y = (0:size(E_dy, 1))*pix;                                                  % Reactor height

% Plot average voidage distribution over time
figure(1);
imagesc(t, y, flipud(voidage_average));
set(gca, 'YDir', 'normal');
xlabel('Time (s)');
ylabel('Y (cm)');
title('Average voidage distribution over time');
colorbar;

% Plot voidage distribution of the last image 
figure(2);
imagesc(x, y, flipud(epsilon));
set(gca, 'YDir', 'normal');
xlabel('Reactor radius (cm)');
ylabel('Y (cm)');
title('Voidage distribution of the last frame');
colorbar;
