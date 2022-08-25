mex noise_matlab.cpp       %MEX for the C++ noise generation code

im_gt = imread('big_buck_bunny.png');     %load the high quality reference image
gaze_location_x = 0.5;     % gaze location vertical (0,1)
gaze_location_y = 0.5;     % gaze location horizontal (0,1)
foveation_level = 8;       %spatial sigma at 30 degree eccentricity, the spatial sigma increases linearly with eccentricity, starting from the foveal cut-off. 

[I_foveated, I_fov_noised ,I_contrast_enhanced, I_ours, noise_pattern] = noise_enhancement(im_gt,foveation_level,gaze_location_x,gaze_location_y);

%I_foveated : foveated image
%I_fov_noised : foveated image + noise
%I_contrast_enhanced: contrast enhanced image
%I_ours: contrast enhanced image + noise
%noise_pattern: the synthesized noise pattern


