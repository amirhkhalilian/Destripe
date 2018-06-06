clc; clear; close all;

im_cor = double(imread('data/Megaphragama122017-1 16x16x16nm2000.tif'));
[m,n] = size(im_cor);
cFFT = fft2(im_cor,m,n);


cFFTabs = abs(cFFT);
cFFTabs(find(cFFTabs<=1e4))=1e4;
cFFTabs(find(cFFTabs>=1e6))=1e6;
figure;
imagesc(ifftshift(cFFTabs));


%% create damping filter
sigma = 30;
damp = 1-exp(-[-floor(m/2):-floor(m/2)+m-1].^2/(2*sigma^2));
filter = repmat(damp',1,n);
% filter(:,2450:2550) = 1;

fFFT = cFFT.*ifftshift(filter);
cFFTabs = abs(fFFT);
cFFTabs(find(cFFTabs<=1e4))=1e4;
cFFTabs(find(cFFTabs>=1e6))=1e6;
figure;
imagesc(cFFTabs);

rec = ifft2(fFFT);


% %% filtering the fft
% rFFT = fftshift(cFFT).*filter;
% rFFTabs = abs(rFFT);
% rFFTabs(find(rFFTabs<=1e4))=1e4;
% rFFTabs(find(rFFTabs>=1e6))=1e6;
% figure;
% imagesc(rFFTabs);
% figure;
% imagesc(real(ifft2(fftshift(rFFT))));
% colormap('gray');
% [cA,cH,cV,cD] = dwt2(im_cor,'db8');

% figure;
% subplot(2,2,1);
% imagesc(cA);colormap('gray');
% axis off;

% subplot(2,2,2)
% imagesc(cH);colormap('gray');
% axis off;


% subplot(2,2,3)
% imagesc(cV);colormap('gray');
% axis off;

% subplot(2,2,4)
% imagesc(cD);colormap('gray');
% axis off;
