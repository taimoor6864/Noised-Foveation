function [I_blurred, I_noised, I_patney, I_patney_noised, noise_pattern] = noise_enhancement(im_gt,sigMax,gaze_x,gaze_y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These parameters an be adjusted based on display specifications and technical preferences

screen_gamma = 2.2;  %the display gamma
width_pixels = 3840; %pixels for the image, we only use 4K 
height_pixels = 2160;  %pixels for the image, we only use 4K
e_cutoff = 12;    %eccentricity cut-off in degrees
width = 120;  %width of the display screen in cm  
height = 67;  %height of the display screen in cm
field_width = 90;   %the total field-of-view the display spans (horizontal)
a_ = 0.08;    %Gabor Kernel Size
number_of_impulses_per_kernel = 64.0;   %numper of impulses-per-gabor-kernel
attenuation = 0.1;  %the attenuation value of spatial frequencies which are deemed preserved for amplitude estimation (default 10%). 
noise_amp = 40;  %s_k
f_sig = 2.2; %s_f
f_e = 0.2; %tuning parameter for contrast enhancement
period = 256; %gabor noise periodicity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ycbcr_max = 219/255;   %for normalization to compensate for MATLAB ycbcr
ycbcr_min = 16/255;


im_gt = imresize(im_gt,[height_pixels width_pixels]);    %resize the image to incase it is smaller or larger than 4K
im_gt = double(im_gt)./255;
sz = size(im_gt);
im_gt = gamma_correction(im_gt,screen_gamma,1);      %linear color space

%suppose looking at screen center, we want the height ends to be at an
%angle of 30 degrees

ppd = (width_pixels/2)/(field_width/2);           %pixels-per-degree
dis = (width/2)/tand(field_width/2);             

gaze_x = round(gaze_x*height);
gaze_y = round(gaze_y*width);

x = linspace(0,height,height_pixels);
y = linspace(0,width,width_pixels);
[Y,X] = meshgrid(y,x);
R = sqrt((X-gaze_x).^2 + (Y-gaze_y).^2);

theta_mat = atand(R./dis);           %pixel-wise eccentricity map

m = sigMax/(30 - e_cutoff);   
c = -m*e_cutoff;
sigma_map = m.*theta_mat + c;        %pixel-wise gaussian-blur sigmas to model foveation
sigma_map(sigma_map<=0) = 0;   
max_sig = ceil(max(sigma_map(:)))+1;

blurred_maps = zeros(sz(1),sz(2),max_sig+1,3);
patney_maps = zeros(sz(1),sz(2),max_sig+1,3);
blurred_maps(:,:,1,:) = im_gt;
patney_maps(:,:,1,:) = im_gt;

for i = 1:max_sig
    blurred_image = imgaussfilt(im_gt,i);
    blurred_maps(:,:,i+1,:) = blurred_image;
    patney_maps(:,:,i+1,:) = contrast_enhancer(blurred_image,i,f_e);
end

[im_blur] = foveation_simulator(blurred_maps,sigma_map);    %foveated image

sz = size(im_blur);
im_blur_ycbcr = rgb2ycbcr(im_blur);
y_channel = im_blur_ycbcr(:,:,1);
cb_channel = im_blur_ycbcr(:,:,2);
cr_channel = im_blur_ycbcr(:,:,3);

[I_patney] = foveation_simulator(patney_maps,sigma_map);   %contrast enhanced image

omega_0 = orientation_map(rgb2gray(im_blur));    %gabor orientations

resolution_x = sz(1);
resolution_y = sz(2);

y_channel_normalized = (double(y_channel)-ycbcr_min)./ycbcr_max;
y_channel_rescaled_i8 = (ycbcr_max.*y_channel_normalized + ycbcr_min);

[Fmin, Fmax] = frequency_map(ppd,y_channel_rescaled_i8,sigma_map,theta_mat,f_sig);    %gabor frequencies

k_map = gabor_amplitude_map(y_channel_normalized,sigma_map,double(rgb2gray(I_patney)),noise_amp,attenuation);    %gabor amplitudes

patch = noise_matlab(resolution_x, resolution_y, k_map, a_, Fmin, Fmax, omega_0, number_of_impulses_per_kernel, period);     %gabor noise synthesis
patch = (patch-mean2(patch));       %gabor noise normalization

I_blurred = ycbcr2rgb(cat(3,y_channel_rescaled_i8,cb_channel,cr_channel));

new_y_channel = y_channel_normalized + patch;     

I_noised = ycbcr2rgb(cat(3,ycbcr_max.*new_y_channel + ycbcr_min,cb_channel,cr_channel));
im_patney_ycbcr = rgb2ycbcr(I_patney);
patney_y_channel = im_patney_ycbcr(:,:,1);
patney_y_channel_normalized = (double(patney_y_channel) - ycbcr_min)./(ycbcr_max);

cb_channel = im_patney_ycbcr(:,:,2);
cr_channel = im_patney_ycbcr(:,:,3);


new_patney_y_channel = patney_y_channel_normalized + patch;
I_patney_noised = ycbcr2rgb(cat(3,(ycbcr_max.*new_patney_y_channel + ycbcr_min),cb_channel,cr_channel));

noise_pattern = patch;

I_patney = uint8(255.*gamma_correction(I_patney,screen_gamma,0));         %contrast enhanced image
I_blurred = uint8(255.*gamma_correction(I_blurred,screen_gamma,0));       %foveated image
I_noised = uint8(255.*gamma_correction(I_noised,screen_gamma,0));         %noised foveated image
I_patney_noised = uint8(255.*gamma_correction(I_patney_noised,screen_gamma,0));   %noised contrast enhanced image (final output)




























