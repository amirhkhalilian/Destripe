clc; clear; close all;

%% Loading data
im_cor = double(imread('Megaphragama122017-1 8x8x8nm-cropped0005.tif'));
[m,n] = size(im_cor);
% wavelet parameters
W_levels = 5;
W_filter = 'db42';
% damping filter design 	might want different sigma for different stages

%% Wavelet Transform and filter
for i = 1:W_levels
	if i ==1
		[cA{i},cH{i},cV{i},cD{i}] = dwt2(im_cor,W_filter);
	else
		[cA{i},cH{i},cV{i},cD{i}] = dwt2(cA{i-1},W_filter);
	end
	[m,n] = size(cV{i});
	cVfft{i} = fft2(cV{i},m,n);
	sigma = 20;
	damp = 1-exp(-[-floor(m/2):-floor(m/2)+m-1].^2/(2*sigma^2));
	filter = repmat(damp',1,n);
	cVifft{i} = ifft2(cVfft{i}.*ifftshift(filter));
end 
%% Wavelet inverse Transform
for i = W_levels:-1:1
	if i == W_levels
		rec{i} = idwt2(cA{i},cH{i},cVifft{i},cD{i},W_filter);
		rec{i}(end,:)=[];
	else
		rec{i} = idwt2(rec{i+1},cH{i},cVifft{i},cD{i},W_filter);
		if i==4
		rec{i}(end,:)=[];
		rec{i}(:,end)=[];
		end
		if i==2
		rec{i}(end,:)=[];
		rec{i}(:,end)=[];
		end
	end
end
figure;
imagesc(rec{1}); colormap('gray');