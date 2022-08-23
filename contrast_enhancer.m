function I_out = contrast_enhancer(I_in,sigma,f_e)

support_size = ceil(2*2*sigma);
filter = ones(support_size)./(support_size^2);
I_avg = imfilter(I_in,filter,'symmetric');
I_out = double(I_avg) + (f_e*(1+sigma)).*(double(I_in) - double(I_avg));
