%% example of use
clc 
clear all 
close all

size = 512;
imagej_zips_path = 'C:\Users\Masih\Desktop\Imagj_zips\';
raw_imgs_path = 'C:\Users\Masih\Desktop\\tissue images\';
results_path = 'C:\Users\Masih\Desktop\results\';
masks_generator(size, imagej_zips_path, raw_imgs_path, results_path)