function [] = plotres(img,rec,plotzoom)
if ~isreal(rec)
	warning('showing the real part of the recovered image');
end
fig1 = figure;
subplot(1,2,1); imagesc(img); colormap gray; axis image; title('original image');
subplot(1,2,2); imagesc(real(rec)); colormap gray; axis image; title('recovered image');
fig2 = figure;
imagesc(abs(img- real(rec))); colormap gray; axis image; title('|img-rec|');
if plotzoom
	figure
	subplot(1,2,1); imagesc(img(800:1200,1600:2000)); colormap gray; axis image; title('original image');
	subplot(1,2,2); imagesc(real(rec(800:1200,1600:2000))); colormap gray; axis image; title('recovered image');
	figure
	imagesc(abs(img(800:1200,1600:2000)- real(rec(800:1200,1600:2000)))); colormap gray; axis image; title('|img-rec|');
end
end