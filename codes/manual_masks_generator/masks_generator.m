function  masks_generator(size_target,imagej_zips_path,raw_imgs_path, results_path )
% author: Amirreza Mahbod 
% contact: amirreza.mahbod@gmail.com

%% inputs:
% size: size of image patches (e.g. 512)
% imagej_zips: path of the created zip files from ImageJ annotation
% raw_imgs_path: raw image pathes path (.png files)
%% Fuction desription: 
% creating the follwoing files form the ImageJ manual annotations
%     - raw binary masks
%     - eroded binary masks
%     - weight maps
%     - distance maps
%     - lable mask
%     - overlaid images (just for visualization)
%% file structure
% main dir --------- raw images folder (contain  'count' image patches)
%          --------- imageJ zip files  (contains 'count' zip files and each zip file contains 'n_num' roi files)
%          --------- masks                            (this directory will be created while running the code)
%          --------- mask binary                      (this directory will be created while running the code)
%          --------- mask binary without border       (this directory will be created while running the code)
%          --------- mask binary without border erode (this directory will be created while running the code)
%          --------- distance maps                    (this directory will be created while running the code)
%          --------- weighted_maps                    (this directory will be created while running the code)
%          --------- weighted_maps_erode              (this directory will be created while running the code)
%          --------- overlay_save_path                (this directory will be created while running the code)
         


mask_overlap = zeros(size_target,size_target);
mask_overlap_modify = zeros(size_target,size_target);

mask_overlap_borderremove = zeros(size_target,size_target);
D_overlap = zeros(size_target, size_target);

imagej_zips = dir(strcat(imagej_zips_path,'*.zip'));
raw_imgs = dir(strcat(raw_imgs_path,'*.tif'));

%% creating required dirs
mkdir(strcat(results_path,'label masks'));
mkdir(strcat(results_path,'mask binary'));
mkdir(strcat(results_path,'mask binary without border'));
mkdir(strcat(results_path,'mask binary without border erode'));
mkdir(strcat(results_path,'distance maps'));
mkdir(strcat(results_path,'weighted_maps'));
mkdir(strcat(results_path,'weighted_maps_erode'));
mkdir(strcat(results_path,'overlay_save_path'));
mkdir(strcat(results_path,'label masks modify'));


% main loop
for counter = 1:length(imagej_zips)
    s = strcat(imagej_zips(counter).folder,'\',imagej_zips(counter).name);
    unzip(s, 'tempfolder');
    ROIs = dir('.\tempfolder\*.roi');
    object_count(counter) = length(ROIs);
    for n_num=1:length(ROIs)
           MaskName = strcat('.\tempfolder\',ROIs(n_num).name); 
           [sROI] = ReadImageJROI(MaskName);
           mask = poly2mask(sROI.mnCoordinates(:,1),sROI.mnCoordinates(:,2), 512, 512);
           mask_org = mask;
           D = bwdist(~mask);
           mask = double(mask)*n_num;
           mask_overlap_modify = max(mask, mask_overlap_modify);
           mask_overlap = mask + mask_overlap;
           D_overlap = max(D ,D_overlap);
           %% for border remove
           eshterak = find(mask_overlap_borderremove == mask_org & mask_overlap_borderremove==1);
           eshterak_img = zeros(512,512);
           eshterak_img(eshterak)=1; 
           mask_overlap_borderremove = max(mask_org, mask_overlap_borderremove);
           if length(eshterak)~=0
           B = edge(mask_org,'nothinning');
           thin_edge = edge(mask_org);
           se = strel('disk', 1);
           B = B & eshterak_img;
           B2 = imdilate(B,strel(se));
           
           mask_overlap_borderremove = mask_overlap_borderremove - B2; 
           mask_overlap_borderremove = mask_overlap_borderremove - thin_edge; 
           mask_overlap_borderremove(mask_overlap_borderremove==-1)=0;
           end
           
    end
    delete tempfolder\*.roi
    %% for masks with diffent label for each object    
    savepath_labelmask = strcat(results_path,'label masks','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.tif'));
    imwrite(uint16(mask_overlap),savepath_labelmask);
    
     %% for masks with diffent label for each object (overlaying areas assign to one object!)    
    savepath_labelmask = strcat(results_path,'label masks modify','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.tif'));
    imwrite(uint16(mask_overlap_modify),savepath_labelmask);
    %% for binary mask
    mask_binary = zeros(512,512);
    mask_binary (mask_overlap>0)= 255;
    mask_binary = uint8(mask_binary);
    savepath_binary = strcat(results_path,'mask binary','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    imwrite(mask_binary,savepath_binary);
    
    %% for mask removing borders like TMI paper
    savepath_binary_borderremoved = strcat(results_path,'mask binary without border','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    mask_overlap_borderremove (mask_overlap_borderremove>0)= 255;
    imwrite(uint8(mask_overlap_borderremove),savepath_binary_borderremoved);
    
    %% for weighted maps
    gt = mask_overlap_borderremove; 
    se = strel('disk', 1);
    gt_erode = imerode(gt,strel(se));
    
    [weight]=unetwmap(gt);
    [weight_erode]=unetwmap(gt_erode);
    weight = weight* 255/max(weight(:));
    weight_erode = weight_erode* 255/max(weight_erode(:));
    
    weighted_maps_path = strcat(results_path,'weighted_maps','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    weighted_maps_erode_path = strcat(results_path,'weighted_maps_erode','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    imwrite(uint8(weight),weighted_maps_path,'Mode','lossless');
    imwrite(uint8(weight_erode),weighted_maps_erode_path,'Mode','lossless');
    
    %% to save the math files (not needed)
    % savepath_math = strcat(results_path,'math_weighted_maps','\', strcat(erase(raw_imgs(counter).name,'.png'),'.png'));
    % savepath_math_erode = strcat(results_path,'math_weighted_maps_erode','\', strcat(erase(raw_imgs(counter).name,'.png'),'.png'));
    % save(savepath_math,'weight')
    % save(savepath_math_erode,'weight_erode')
    
    %% for mask binary without border erode
    se = strel('disk', 1);
    mask_binary_without_border_erode = imerode(mask_overlap_borderremove,strel(se));
    savepath_binary_borderremoved = strcat(results_path,'mask binary without border erode','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    imwrite(uint8(mask_binary_without_border_erode),savepath_binary_borderremoved);
    
    %% for distance maps
    savepath_distance = strcat(results_path,'distance maps','\', strcat(erase(raw_imgs(counter).name,'.tif'),'.png'));
    D_overlap = double(D_overlap);
    D_overlap = D_overlap/max(D_overlap(:)); % otherwise you get bianry image for distance map
    imwrite(D_overlap,savepath_distance,'Mode','lossless');
    
    %% for overliad images
    original= imread(strcat(raw_imgs(counter).folder,'\',raw_imgs(counter).name));
    img_dim = size(original);
    if length(img_dim) ==2
        original = cat(3, original, original, original);
    end
    original_r = original(:,:,1);
    original_g = original(:,:,2);
    original_b = original(:,:,3);

    original_r(mask_overlap~=0) = 255;
    original_g(mask_overlap~=0) = 255;
    original_b(mask_overlap~=0) = 255;

    original2(:,:,1) = original_r;
    original2(:,:,2) = original_g;
    original2(:,:,3) = original_b;
    fig = figure('Renderer', 'painters', 'Position', [10 10 1500 750]);
    subplot(1,2,2);imshow(original2); title({'overlay'},'FontSize', 22);
    for i=1:length(ROIs)
        dum = mask_overlap;
        dum(mask_overlap~=i)=0;
        hold on
        visboundaries(dum,'Color','b','LineWidth', 1,'LineStyle', '-');
    end
    subplot(1,2,1);imshow(original);title({'cropped image'},'FontSize', 22);
    
    save_path_overlay = strcat(results_path,'overlay_save_path','\',raw_imgs(counter).name);

    saveas(fig, save_path_overlay);
    
    mask_overlap = zeros(size_target,size_target);
    mask_overlap_modify = zeros(size_target,size_target);
    mask_overlap_borderremove = zeros(size_target,size_target);
    D_overlap = zeros(512,512);
    %counter
%     formatSpec = 'number of  %4.2f meters or %8.3f mm\n';
%     fprintf(formatSpec,A1,A2)
    raw_imgs(counter).name 
    object_count(counter)

    fprintf('==========\n')
    %raw_imgs(counter).name
    close all
end

%fprintf(object_count, erase(raw_imgs(counter).name,'.tif'))
sum(object_count(:))
end

