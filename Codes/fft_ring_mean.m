clc; clear; close all;
%% Load image
img = double(imread('Megaphragama122017-1 8x8x8nm-cropped0005.tif'));
[m,n] = size(img);
%% fft calculation
im_fft = fft2(img);
img_fft_shift = fftshift(im_fft);
%% Plot fft
figure;
imagesc(log10(abs(img_fft_shift)));
colormap('gray');
axis image;
%% Ring parameters
center = floor(size(img_fft_shift)/2)+1;
ring_radius = 200;
ring_halfwidth = 10;
allout = 0; 	% consider all outliers
%% find points in the ring
for ring_radius = 30:20:1000
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

cutoff = mean(abs(fft_in_ring))+3*std(abs(fft_in_ring));

outlier_ind = find(abs(fft_in_ring)>=cutoff);
inside_ind = find(abs(fft_in_ring)<cutoff);
mean_real = mean(real(fft_in_ring(inside_ind)));
std_real = std(real(fft_in_ring(inside_ind)));
mean_imag = mean(imag(fft_in_ring(inside_ind)));
std_imag = std(imag(fft_in_ring(inside_ind)));
img_fft_shift_copy = img_fft_shift;
for i =1:length(outlier_ind)/2
	if allout==1
		img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = mean_real+1j*mean_imag;
		img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = mean_real-1j*mean_imag;
	else
		if angles(outlier_ind(i))<=0.1&&angles(outlier_ind(i))>=-0.1
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = mean_real+1j*mean_imag;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = mean_real-1j*mean_imag;
		elseif angles(outlier_ind(i))>=pi-0.1
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = mean_real+1j*mean_imag;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = mean_real-1j*mean_imag;
		elseif angles(outlier_ind(i))<=-pi+0.1
			img_fft_shift(pos_x(outlier_ind(i)),pos_y(outlier_ind(i))) = mean_real+1j*mean_imag;
			img_fft_shift(pos_x(end-outlier_ind(i)+1),pos_y(end-outlier_ind(i)+1)) = mean_real-1j*mean_imag;
		end
	end
end		
for i = 1:length(pos_x)
	fft_in_ring_modif(i) = img_fft_shift(pos_x(i),pos_y(i));
end
% figure;
% polarscatter(angles,abs(fft_in_ring_modif),'.');
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




