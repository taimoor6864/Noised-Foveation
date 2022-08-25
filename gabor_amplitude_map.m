function noise_map = gabor_amplitude_map(im_in,sigma_map,im_patney,k_amp,attenuation)
pyr_clip = [2049 3585];
normal_image_size = [2160 3840];
im_in = imresize(im_in,pyr_clip); %to compensate for pyramid resizing
max_min_nhood = 25;  %Nhood size for amplitude modulation for mitigate clipping

levels = 10;
type = 'laplace';
pyr_blur = genPyr(im_in,type,levels);   %laplacian pyramid

level_midFreq = [0.5/(2^0.5) 0.5/(2^1.5) 0.5/(2^2.5) 0.5/(2^3.5) 0.5/(2^4.5) 0.5/(2^5.5) 0.5/(2^6.5) 0.5/(2^7.5) 0.5/(2^8.5)];    %spatial frequency limits for pyramid bands

sigma_f_map = ((2.*pi.*sigma_map).^-1);    %conversion of spatial blur sigmas into freq domain sigma
cutoff_freq_map = sqrt(-2.*(sigma_f_map.^2).*log(attenuation));   %cutoff frequencies at each pixel location
cutoff_freq_map(cutoff_freq_map>0.5) = 0.5;    %limiting to the screen resolution

pyr_req_level = log2(0.5./cutoff_freq_map) + 0.5;   %closed form expression for finding the correct pyramid level
pyr_req_level = floor(pyr_req_level);
pyr_other_level = pyr_req_level + 1;
pyr_other_level(pyr_req_level == 0) = 1;
pyr_req_level(pyr_req_level < 1) = 1;

midFreq_mat_req_level = level_midFreq(pyr_req_level);
midFreq_mat_other_level = level_midFreq(pyr_other_level);

nhood_label = ones(max_min_nhood);
max_image = double(imdilate(im_patney,nhood_label,'same'));
min_image = double(imerode(im_patney,nhood_label,'same'));
filter = ones(3,3)./9;
pyr_averaged = cell(levels,1);     
for k = 1:levels                   
    pyr_averaged{k} = conv2(abs(pyr_blur{k}),filter,'same');      %averaging to smoothen zero-crossings in the laplacian pyramid
    pyr_averaged{k} = imresize(pyr_averaged{k},normal_image_size);
end

M_i = transpose(1:normal_image_size(1))*ones(1,normal_image_size(2));
M_j = transpose(transpose(1:normal_image_size(2))*ones(1,normal_image_size(1)));

pyr_averaged = horzcat(pyr_averaged{:});
pyramid_mat = reshape(pyr_averaged,normal_image_size(1),normal_image_size(2),[]);

dis_req_level = abs(log2(cutoff_freq_map) - log2(midFreq_mat_req_level));
dis_other_level = abs(log2(cutoff_freq_map) - log2(midFreq_mat_other_level));

norm_dis_req_level = dis_req_level./(dis_req_level + dis_other_level);
norm_dis_other_level = dis_other_level./(dis_req_level + dis_other_level);

ind_low = sub2ind(size(pyramid_mat),M_i(:),M_j(:),pyr_req_level(:));
ind_high = sub2ind(size(pyramid_mat),M_i(:),M_j(:),pyr_other_level(:));

noise_map = pyramid_mat(ind_low).*norm_dis_other_level(:) + pyramid_mat(ind_high).*norm_dis_req_level(:);
noise_map = reshape(noise_map,[normal_image_size(1) normal_image_size(2) 1]);
noise_map = (k_amp*3.5722).*noise_map;      %scaled with constant approximate compensation for varaince scaling during noise-synthesis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%saturation control 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp_store_high = noise_map;
temp_store_low = noise_map;

index_sat_high = (noise_map./2 + max_image) > 1;
temp_store_high(index_sat_high) = 2.*(1 - max_image(index_sat_high));
temp_store_high = min(temp_store_high, noise_map);

index_sat_low = (min_image - noise_map./2) < 0;
temp_store_low(index_sat_low) = 2.*(min_image(index_sat_low));
temp_store_low = min(temp_store_low, noise_map);

noise_map = min(temp_store_high, temp_store_low);

noise_map(sigma_map == 0) = 0;
noise_map = imresize(noise_map,[2160 3840]);





    

