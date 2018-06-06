clc; clear; close all;

im_cor = imread('data/Megaphragama122017-1 16x16x16nm2000.tif');
im_cor = imrotate(im_cor,90);

[H,T,R] = hough(im_cor,'RhoResolution',1,'ThetaResolution',0.5);