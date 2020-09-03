%% example of use
clc 
clear all 
close all

size_target = 512;
imagej_zips_path = '..\imageJ_zips\';
raw_imgs_path = '..\images\';
results_path = '..\results\';
masks_generator(size_target, imagej_zips_path, raw_imgs_path, results_path)