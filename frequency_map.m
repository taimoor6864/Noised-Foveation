function [Fmin, Fmax] = frequency_map(ppd,y_channel,sigma_map,theta_mat,f_sig)
sz = size(y_channel);
n = sz(1);
k = sz(2);
sigma_cutoff_factor = 3;    

theta = [0 5 10 15 20 25 30 35 70];    %eccentricity
nasal_lower = [50 15 12 8 7 6 4 3 2];     %resolvibility limits
nasal_higher = [150 42 42 38 36 34 32 30 30];   %detectability limits

nasal_higher = nasal_higher./2;    %halving the detectabiity limits to improve visibility

lowF_thibos_cpd = interp1(theta,nasal_lower,theta_mat);
highF_thibos_cpd = interp1(theta,nasal_higher,theta_mat);

lowF_thibos_cpp = lowF_thibos_cpd.*(ppd^-1);
highF_thibos_cpp = highF_thibos_cpd.*(ppd^-1);
highF_thibos_cpp(highF_thibos_cpp > 0.5) = 0.5;  %let maximum cpp be 0.5
lowF_thibos_cpp(lowF_thibos_cpp > 0.5) = 0.5; 
sigma_cutoff_cpp = sigma_cutoff_factor.*((2.*pi.*sigma_map).^-1);

sigma_cutoff_cpp(isinf(sigma_cutoff_cpp)) = 0.5;
sigma_cutoff_cpp(sigma_cutoff_cpp>0.5) = 0.5;
lowF_thibos_cpp(lowF_thibos_cpp < sigma_cutoff_cpp) = sigma_cutoff_cpp(lowF_thibos_cpp < sigma_cutoff_cpp);  %only add frequencies higher than cutoff as lower freq's are already preserved. 
%norm_mat = load('norm_mat.mat').norm_mat;  %pre-calculated random numbers from a standard normal distribution


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sampling from eccentricity dependent log-normal distributions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sz = size(sigma_cutoff_cpp);
M_i = transpose(1:sz(1))*ones(1,sz(2));
M_j = transpose(transpose(1:sz(2))*ones(1,sz(1)));
mu_mat = (log(highF_thibos_cpp) + (log(lowF_thibos_cpp)))./2;
sig_mat = abs(f_sig.*(mu_mat - log(lowF_thibos_cpp))./2);
norm_mat = normrnd(0,1,[sz 10]);  % recommend to use a pre-calculated norm_mat across all video frames for temporal consistency

g_arr = mu_mat + sig_mat.*norm_mat;
g_arr(g_arr >= log(highF_thibos_cpp)) = NaN;

temp1 = cat(3,ones(sz),2.*ones(sz),3.*ones(sz),4.*ones(sz),5.*ones(sz),6.*ones(sz),7.*ones(sz),8.*ones(sz),9.*ones(sz),10.*ones(sz));
temp2 = (~isnan(g_arr)).*temp1;
temp2 = max(temp2,[],3);
temp2(temp2 == 0) = 1;
idx = sub2ind(size(g_arr),M_i(:),M_j(:),temp2(:));
g_arr = g_arr(idx);
g_arr = reshape(g_arr,[sz(1) sz(2)]);
g_arr(isnan(g_arr)) = mu_mat(isnan(g_arr));
   
r = exp(g_arr);
Fmin = r;
Fmax = r + 0.0001;


        









