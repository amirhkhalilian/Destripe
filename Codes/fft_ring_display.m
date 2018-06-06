clc; clear; close all;
%% Load image
% img = double(imread('Megaphragama122017-1 8x8x8nm-cropped0005.tif'));

% img = double(imread('circles.jpg'));
img = imread('circles.jpg');
img = imgaussfilt(img,1);
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
center = floor(size(img_fft_shift)/2)+1;
ring_radius_init = 30;
ring_radius_end = 1023;
ring_halfwidth = 10;
allout = 0; 	% consider all outliers
angle_threshold = 0.1;
random_on = 1;
cutoff_threshold = 2;

%%plotting initialization
fig2 = figure(2);
polar_before = polarscatter(0,abs(0),'.');
title('polar before');
fig3 = figure(3);
polar_after = polarscatter(0,abs(0),'.');
title('polar after');
fig4 = figure(4);
im_test = imagesc(log10(abs(img_fft_shift_copy))); colormap('gray'); axis image;
ginput(1);

%% find points in the ring
for ring_radius = ring_radius_init:2*ring_halfwidth:ring_radius_end
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
test = img_fft_shift;
temp = abs(img_fft_shift);
temp = max(temp(:));

for i = 1:length(pos_x)
	fft_in_ring(i) = img_fft_shift(pos_x(i),pos_y(i));
	test(pos_x(i),pos_y(i)) = temp;
end

cutoff = mean(abs(fft_in_ring))+cutoff_threshold*std(abs(fft_in_ring));

outlier_ind = find(abs(fft_in_ring)>=cutoff);
inside_ind = find(abs(fft_in_ring)<cutoff);
mean_real = mean(real(fft_in_ring(inside_ind)));
std_real = std(real(fft_in_ring(inside_ind)));
mean_imag = mean(imag(fft_in_ring(inside_ind)));
std_imag = std(imag(fft_in_ring(inside_ind)));

for i =1:length(outlier_ind)/2
	sample = (mean_real+random_on*std_real*randn)+1j*(mean_imag+random_on*std_imag*randn);
	if allout==1
		img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = sample;
		img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = conj(sample);
	else
		if angles(outlier_ind(i))<=angle_threshold&&angles(outlier_ind(i))>=-angle_threshold
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = sample;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = conj(sample);
		elseif angles(outlier_ind(i))>=pi-angle_threshold
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = sample;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = conj(sample);
		elseif angles(outlier_ind(i))<=-pi+angle_threshold
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = sample;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = conj(sample);
		end
	end
end		
for i = 1:length(pos_x)
	fft_in_ring_modif(i) = img_fft_shift(pos_x(i),pos_y(i));
end
% figure(2);
% polarscatter(angles,abs(fft_in_ring),'.');
% title('polar before');
% figure(3);
% polarscatter(angles,abs(fft_in_ring_modif),'.');
% title('polar before');
% figure(4);
% imagesc(log10(abs(test))); colormap('gray'); axis image;
% drawnow;

polar_before.RData = abs(fft_in_ring);
polar_before.ThetaData = angles;

polar_after.RData = abs(fft_in_ring_modif);
polar_after.ThetaData = angles;

im_test.CData = log10(abs(test));
pause(.1);

end

rec = ifft2(ifftshift(img_fft_shift));
plotres(img,rec,1)


% zero_angle_ind = find(angles>=-0.1&angles<=0.1);
% zero_angle_ind = [zero_angle_ind;find(angles>=pi-0.1)];
% zero_angle_ind = [zero_angle_ind;find(angles<=-pi+0.1)];




% figure;
% imagesc(log10(abs(test))); colormap('gray');
% axis image;
% cutoff = mean(abs(fft_in_ring))+3*std(abs(fft_in_ring));
% figure;
% polarscatter([angles;(0:0.01:2*pi)'],[abs(fft_in_ring),cutoff*ones(size(0:0.01:2*pi))],'.');




