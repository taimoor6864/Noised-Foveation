function im_t = gamma_correction(im_in,screen_gamma,mode)

if(mode == 0)
   im_t = 1.055.*(im_in.^(1/screen_gamma)) - 0.055;
else
   im_t = ((im_in + 0.055)./1.055).^screen_gamma;
end

