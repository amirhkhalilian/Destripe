clc; clear; close all;
%% Load image
img = double(imread('Megaphragama122017-1 8x8x8nm-cropped0005.tif'));

[m,n] = size(img);
%% fft calculation
im_fft = fft2(img);
img_fft_shift = fftshift(im_fft);
img_fft_shift_copy = img_fft_shift;
%% Plot fft
figure;
imagesc(log10(abs(img_fft_shift)));
colormap('gray');
axis image;
%% Ring parameters
[center,...
 ring_radius_init,...
 ring_radius_end,...
 ring_halfwidth] = ring_initialize(img_fft_shift);

%% Program parameters and modes
allout = 0; 	% consider all outliers
angle_threshold = 0.1;
random_on = 1;
cutoff_threshold = 0.05;

%% Plotting initialization
[im_p_value, polar_before, im_outray, im_inray]=Plot_initilize(img_fft_shift);

%% Start
for ring_radius = ring_radius_init:2*ring_halfwidth:ring_radius_end
	[pos_x,pos_y,angles] = get_ring_pos(ring_radius,ring_halfwidth,center);

	test = img_fft_shift;
	temp = abs(img_fft_shift);
	temp = max(temp(:));

	for i = 1:length(pos_x)
		fft_in_ring(i) = img_fft_shift(pos_x(i),pos_y(i));
		test(pos_x(i),pos_y(i)) = temp;
	end	

	outray_ind = [find(angles>=angle_threshold&angles<=pi- angle_threshold);...
				  find(angles>=angle_threshold-pi&angles<=-angle_threshold)];
	inray_ind = [find(angles>=-angle_threshold&angles<=angle_threshold);...
				 find(angles>=pi-angle_threshold);...
				 find(angles<=-pi+angle_threshold)];

	[Mu,Sigma,p_values] = fit_2D_gaussian(fft_in_ring,outray_ind);
	
	for i = 1:length(pos_x)
		p_value_mask(pos_x(i),pos_y(i)) = p_values(i);
	end

	im_p_value.CData = p_value_mask;

	polar_before.RData = abs(fft_in_ring);
	polar_before.ThetaData = angles;

	im_test.CData = log10(abs(test));

	im_outray.XData = real(fft_in_ring(outray_ind));
	im_outray.YData = imag(fft_in_ring(outray_ind));

	im_inray.XData = real(fft_in_ring(inray_ind));
	im_inray.YData = imag(fft_in_ring(inray_ind));
	pause(.3);
end

function [center, ring_radius_init, ring_radius_end, ring_halfwidth] = ring_initialize(img_fft_shift)
	center = floor(size(img_fft_shift)/2)+1;
	ring_radius_init = 30;
	ring_radius_end = min(center)-1;
	ring_halfwidth = 10;
end

function [im_p_value, polar_before, im_outray, im_inray]=Plot_initilize(img_fft_shift)
	p_value_mask = zeros(size(img_fft_shift));
	fig1 = figure(1);
	im_p_value = imagesc(p_value_mask); colormap('hot'); colorbar;
	title('p-value mask');

	fig2 = figure(2);
	im_test = imagesc(log10(abs(img_fft_shift))); colormap('gray'); axis image;

	fig3 = figure(3);
	polar_before = polarscatter(0,abs(0),'.');
	title('polar before');

	fig4 = figure(4);
	im_outray = scatter(0,0,'b*');
	hold on
	im_inray = scatter(0,0,'ro');
	ginput(1);

end


function [pos_x,pos_y,angles] = get_ring_pos(ring_radius,ring_halfwidth,center)
	x =  [-ring_radius-ring_halfwidth:ring_radius+ring_halfwidth];
	y =  [-ring_radius-ring_halfwidth:ring_radius+ring_halfwidth];
	[X,Y] = meshgrid(x,y);
	Norms = sqrt(X.^2+Y.^2);
	ind = find(Norms>=ring_radius-ring_halfwidth & Norms<=ring_radius+ring_halfwidth);
	pos_x = X(ind);
	pos_y = Y(ind);
	pos = [pos_x,pos_y];
	angles = atan2(pos_x,pos_y);
	pos_x = center(1)+X(ind);
	pos_y = center(2)+Y(ind);
end

function [Mu,Sigma,p_values] = fit_2D_gaussian(fft_in_ring,outray_ind);

	Data = [real(fft_in_ring(outray_ind))',imag(fft_in_ring(outray_ind))'];
	Mu = mean(Data);
	Sigma = cov(Data);
	p_values = mvncdf([real(fft_in_ring)',imag(fft_in_ring)'],Mu,Sigma);
	p_values(find(p_values>=0.5))= 1-p_values(find(p_values>=0.5));
end