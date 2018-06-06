clc; clear; close all;

%% Loading data
im_cor = double(imread('data/Megaphragama122017-1 16x16x16nm2000.tif'));
[m,n] = size(im_cor);
% wavelet parameters
W_levels = 5;
W_filter = 'db42';
% LoG filter design
sigma = 2;
h = fspecial('log',[11,11],sigma);
%% Wavelet Transform and filter
for i = 1:W_levels
	if i ==1
		[cA{i},cH{i},cV{i},cD{i}] = dwt2(im_cor,W_filter);
		cV_LoG{i} = imfilter(cV{i},h);
	else
		[cA{i},cH{i},cV{i},cD{i}] = dwt2(cA{i-1},W_filter);
		cV_LoG{i} = imfilter(cV{i},h);
	end
end 
%% Wavelet inverse Transform
for i = W_levels:-1:1
	if i == W_levels
		rec{i} = idwt2(zeros(size(cA{i})),zeros(size(cH{i})),cV_LoG{i},zeros(size(cD{i})),W_filter);
		rec{i}(end,:)=[];
	else
		rec{i} = idwt2(rec{i+1},zeros(size(cH{i})),cV_LoG{i},zeros(size(cD{i})),W_filter);
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
imagesc(histeq(rec{1})); colormap('gray');