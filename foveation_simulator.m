function [I_out] = foveation_simulator(blurred_maps,sigma_map)
  %sigma at 30 degrees eccentricity  %18

sz = size(sigma_map);

M_i = transpose(1:sz(1))*ones(1,sz(2));
M_j = transpose(transpose(1:sz(2))*ones(1,sz(1)));

sig_low = floor(sigma_map);
sig_high = ceil(sigma_map);

sig_frac1 = (sigma_map) - sig_low;
sig_frac2 = 1 - sig_frac1;

sig_low_ind = sig_low + 1;
sig_high_ind = sig_high + 1;

c = ones(sz);
ind_low = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_low_ind(:),c(:));
ind_high = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_high_ind(:),c(:));
foveated_R = blurred_maps(ind_low).*sig_frac2(:) + blurred_maps(ind_high).*sig_frac1(:);
foveated_R = (reshape(foveated_R,[2160 3840 1]));

c = 2.*ones(sz);
ind_low = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_low_ind(:),c(:));
ind_high = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_high_ind(:),c(:));
foveated_G = blurred_maps(ind_low).*sig_frac2(:) + blurred_maps(ind_high).*sig_frac1(:);
foveated_G = (reshape(foveated_G,[2160 3840 1]));

c = 3.*ones(sz);
ind_low = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_low_ind(:),c(:));
ind_high = sub2ind(size(blurred_maps),M_i(:),M_j(:),sig_high_ind(:),c(:));
foveated_B = blurred_maps(ind_low).*sig_frac2(:) + blurred_maps(ind_high).*sig_frac1(:);
foveated_B = (reshape(foveated_B,[2160 3840 1]));

I_out = cat(3,foveated_R,foveated_G,foveated_B);

