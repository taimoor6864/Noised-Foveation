mex noise_matlab.cpp       %MEX file for the C++ noise generation code

im_gt = imread('sponza.jpg');     %load the high quality reference image
gaze_location_x = 0.5;     % gaze location vertical (0,1)
gaze_location_y = 0.5;     % gaze location horizontal (0,1)
foveation_level = 8;       %spatial sigma at 30 degree eccentricity

[I_blurred, I_noised, I_patney, I_ours, noise_pattern] = noise_enhancement(im_gt,foveation_level,gaze_location_x,gaze_location_y);

%I_blurred : foveated image
%I_noised: foveated image + noise
%I_patney: contrast enhanced image
%I_ours: contrast enhanced image + noise
%noise_pattern: the synthesized noise pattern

