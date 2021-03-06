# CryoNuSeg: A Dataset for Nuclei Segmentation of Cryosectioned H\&E-Stained Histological Images
[![Generic badge](https://img.shields.io/badge/Code-MATLAB-<COLOR>.svg)](https://shields.io/)

CryoNuSeg is the first fully annotated dataset of frozen H\&E-Stained histological images. The dataset includes 30 image patches with a fixed size of 512x512 pixels of 10 human organs. <a href="https://portal.gdc.cancer.gov/">The Cancer Genome Atlas (TCGA)</a> was the main source for creating this dataset.  

![Project Image](https://github.com/masih4/CryoNuSeg/blob/master/.gitfiles/example.jpg)



## Table of Contents 
[Citation](#citation)

[Link to full dataset](#link-to-full-dataset)

[WSI selection](#wsi-selection)

[WSI patch extraction](#wsi-patch-extraction)

[Manual annotation with ImageJ](#manual-annotation-with-imagej)

[Codes to generate segmentation masks](#codes-to-generate-segmentation-masks)

[Acknowledgements](#acknowledgements)





## Citation
Our published paper is publicy available on ScienceDirect (open access):
https://www.sciencedirect.com/science/article/pii/S0010482521001438

BibTex entry:
```
@article{CryoNuSeg2021,
title = "{CryoNuSeg}: A dataset for nuclei instance segmentation of cryosectioned H\&E-stained histological images",
journal = "Computers in Biology and Medicine",
volume = "132",
pages = "104349",
year = "2021",
issn = "0010-4825",
doi = "https://doi.org/10.1016/j.compbiomed.2021.104349",
url = "https://www.sciencedirect.com/science/article/pii/S0010482521001438",
author = "Amirreza Mahbod and Gerald Schaefer and Benjamin Bancher and Christine L\"{o}w and Georg Dorffner and Rupert Ecker and Isabella Ellinger"
}
```
## Link to full dataset
The full dataset with the corresponding generated segmentation masks are available on the Kaggle website: 
https://www.kaggle.com/ipateam/segmentation-of-nuclei-in-cryosectioned-he-images

## WSI Selection
To extract the patches from the TCGA database, we did the following steps:
- 1- Go to: https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga
- 2- Click on "Access TCGA Data"
- 3- Click on "Repository"
- 4- From the left panel in the "Data Type" section select "svs" type. There are more than 30000 WSIs in the database. 
- 5- Again from the left panel in the "Access" section, select "open" files. At the time of writing this guideline (2020-09-03), all .svs files have the open-access format. 
- 6- Again from the left panel in the "Experimental Strategy" section select "Tissue slide". (Tissue slide represent FS samples and diagnostic slide represent FFPE samples)
- 7- All the above three selections were chosen from the left panel while the "Files" tap was open. Now switch to the "Cases" tap. 
- 8- From the "Primary site," you are able to select the organs. In this study, we chose 10 organs that were not widely used in the other publicly available datasets. We chose the adrenal gland, larynx, lymph nodes, mediastinum, pancreas, pleura, skin, testes, thymus, and thyroid gland. 
- 9- For each organ, we selected 3 WSIs at 40x magnification. A senior biologist at the Medical University of Vienna helped us with the WSI selection. We selected the WSIs from different patient and different tissue center based on the provided barcodes (further information about the barcodes: https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/). The full description of the selected WSIs with meta data such as gender, sex, etc can be found in "Selected_WSIs.xlsx" in the repository files. 
- Alternatively, the advanced search option could be used to replace step 4 to 8 (i.e. by seraching for: 
```files.access in ["open"] and files.data_format in ["svs"] and files.experimental_strategy in ["Diagnostic Slide","Tissue Slide"] AND cases.samples.is_ffpe = false```)

## WSI patch extraction
To extract image patches with a fixed size of 512x512 pixels we used QuPath software (https://qupath.github.io/). We performed the following steps:
- Open the downloaded .svs file with QuPath.
- Go to Automate --> show script editor 
- Copy and paste the following code and run it:
```// Script to create a 512 x 512 rectangle ROI in Qupath
import qupath.lib.roi.RectangleROI
import qupath.lib.objects.PathAnnotationObject
// Adapted from:
// https://github.com/qupath/qupath/issues/137
// Size in pixels at the base resolution
int size = 511

// Get center pixel
def viewer = getCurrentViewer()
int cx = viewer.getCenterPixelX()
int cy = viewer.getCenterPixelY()

// Create & add annotation
def roi = new RectangleROI(cx-size/2, cy-size/2, size, size)
def annotation = new PathAnnotationObject(roi)
addObject(annotation)
```
- A square box with the preferred size (512x512 pixel in this project) will appear on the screen. Move the box to a proper position where you would like to extract the patch.
- then use Extension --> ImageJ --> send region to ImageJ (downsample factor = 1)
- The image will appear on ImageJ software and then you could perform manual segmentation (see next session)
## Manual annotation with ImageJ
We used ImageJ software to perform manual nuclei instance segmentation. We followed these steps to manually annotate the images:
- open an image with the software
- From tabs:  Analyse --> Tools --> ROI manager. Make sure that both "show all" and "labels" are activated in the ROI manager. 
- Zoom in/out to have a clear view of the image and all instances
- from the selection options, select "freehand selection"
- manually annotate the border for each object and press "T". To remove an object select the labeled number inside the object and then press "Delete"
- to remove an ROI 
- When you are done with all nuclei, save the outputs with ROI manager--> More --> Save
- A zip file containing a number of ROI files will be created after saving the outputs (each ROI file represent one of the nucleus) 

## Codes to generate segmentation masks
The Matlab codes to generate the segmentation masks are available in the  <a href="https://github.com/masih4/CryoNuSeg/tree/master/codes/manual_masks_generator
">codes folder</a>. Besides the conventional binary masks, we also created some auxiliary segmentation masks that may be helpful in developing supervised machine learning-based algorithms.  

## Acknowledgements
This work was supported by the Austrian Research Promotion Agency (FFG),<a href="https://projekte.ffg.at/projekt/3258628"> No. 872636</a> and the <a href="https://www.kaggle.com/open-data-research-grant-2020-awardees">Kaggle open data research grant</a>.






