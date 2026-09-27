%--------------------------------------------------------------------------
%% load 3D-GRE data (low resolution to save space)
%--------------------------------------------------------------------------

load img_fully_sampled_3mm      % img : input 4D coil images in (x, y, z, chan)


img_rsos = sum(abs(img).^2, 4).^0.5;


N = size(img_rsos);
rot_disp = [-90,-90,180];


imagesc3d2(img_rsos, N/2, 1, rot_disp, [0,5e-6], 0, 'Root Sum of Square')


%--------------------------------------------------------------------------
%% SVD coil compression:
% the first eigenmode has smooth phase devoid of singularities at 3T
% this can be used as phase reference to remove anatomical phase from coil 
% sensitivities without introducing singularities
%--------------------------------------------------------------------------

num_svd = 16;                   % no of SVD channels for compression (num_svd = 16 works well for 32 chan array)

temp = reshape(img, [prod(N), size(img,4)]);

[V,D] = eig(temp'*temp);
V = flipdim(V,2);


% coil compressed image, where 1st chan is the virtual body coil to be used as phase reference:
img_svd = reshape(temp * V(:,1:num_svd), [N, num_svd]);


img_svd_rsos = sum(abs(img_svd).^2, 4).^0.5;


rmse_svd = 100 * norm( img_rsos(:) - img_svd_rsos(:) ) / norm(img_rsos(:));


imagesc3d2(img_svd_rsos, N/2, 2, rot_disp, [0,5e-6], 0, ['SVD: Root Sum of Square: ', num2str(rmse_svd), ' % RMSE'])


%--------------------------------------------------------------------------
%% ESPIRiT requires BART -> install version 0.2.06 and add to path
%--------------------------------------------------------------------------

cd bart-0.2.06/

system('make')

cd ..


bart_path = [pwd, '/bart-0.2.06/'];

setenv('TOOLBOX_PATH', bart_path)
addpath(strcat(getenv('TOOLBOX_PATH'), '/matlab'));
setenv('PATH', strcat(getenv('TOOLBOX_PATH'), ':', getenv('PATH')));
setenv('LD_LIBRARY_PATH', '');


%--------------------------------------------------------------------------
%% ESPIRiT sensitivity estimation:
%--------------------------------------------------------------------------

num_acs = 16;                   % size of calibration region for sensitivity estimation (doesn't change the result too much)
c = 0.4;                        % mask size for coil sensitivities, smaller "c" provides larger mask        


writecfl('img_svd', single(img_svd))


% run ESPIRiT:
system(['fft 7 ', 'img_svd ', 'kspace_svd'])
system(['ecalib -r ', num2str(num_acs), ' -c ', num2str(c), ' kspace_svd ', 'calib_svd'])
system(['slice 4 0 ', 'calib_svd ', 'sens_svd'])


% clean up space:
system('rm calib_svd.hdr')
system('rm calib_svd.cfl')

system('rm kspace_svd.hdr')
system('rm kspace_svd.cfl')

system('rm img_svd.hdr')
system('rm img_svd.cfl')


sens_svd = single(readcfl('sens_svd'));    % estimated coil sensitivities


% use ESPIRiT sensitivities for Roemer/SENSE coil combination:
img_combo = sum(img_svd .* conj(sens_svd), 4) ./ (eps + sum(abs(sens_svd).^2, 4));


imagesc3d2(img_combo, N/2, 3, rot_disp, [0,5e-6], 0, 'Magnitude: coil combined volume')
imagesc3d2(angle(img_combo), N/2, 4, rot_disp, [-pi,pi], 0, 'Phase: coil combined volume')


