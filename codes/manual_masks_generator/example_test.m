%% example of use
clc 
clear all 
close all

size_target = 512;
% imagej_zips_path = '..\imageJ_zips\';
% raw_imgs_path = '..\images\';
% results_path = '..\results\';

imagej_zips_path = 'C:\Masih\research\PhD\projects\intraoperative histology samples\data\Christine_final\Imagj_zips\';
raw_imgs_path = 'C:\Masih\research\PhD\projects\intraoperative histology samples\data\tissue images\';
results_path = 'C:\Masih\research\PhD\projects\intraoperative histology samples\data\Christine_final_with_nuclei_border\';


masks_generator(size_target, imagej_zips_path, raw_imgs_path, results_path)

% %% to count number of segmented cells in label masks
% srcFiles_label = dir('..\label masks modify\*.tif');  
% count_cell_crop = zeros(length(srcFiles_label),1);
% for i = 1:length(srcFiles_label)
%     filename_label = strcat(srcFiles_label(i).folder,'\',srcFiles_label(i).name);
%     label = imread(filename_label);
%     count_cell_crop(i) = length(unique(label))-1;
% end
% sum(count_cell_crop)