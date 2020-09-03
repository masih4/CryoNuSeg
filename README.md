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

[Acknowledgements](#acknowledgements)





## Citation
The full description of the dataset can be found in the following article:

BibTex entry:
```
@inproceedings{Manhbod_isbi_2021,
  title="CryoNuSeg: A Dataset for Nuclei Segmentation of Cryosectioned H\&E-Stained Histological Images",
  author="Mahbod, A and Schaefer, G and Bancher, B and L\"{o}, C and Dorffner, G and Ecker, R and Ellinger, R",
  booktitle="International Symposium on Biomedical Imaging",
  pages="",
  year="2021",
  organization="IEEE"
}
```
## Link to full dataset
The full dataset with the corresponding generated segmentation masks are available on the Kaggle website: 
https://www.kaggle.com/ipateam/segmentation-of-nuclei-in-cryosectioned-he-images

## WSI Selection
To extract the patches from the TCGA database, we did the following steps:
- Go to: https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga
- Click on "Access TCGA Data"
- Click on "Repository"
- From the left panel in the "Data Type" section select "svs" type. There are more than 30000 WSIs in the database. 
- Again from the left panel in the "Access" section, select "open" files. At the time of writing this guideline (2020-09-03), all .svs files have the open-access format. 
- Again from the left panel in the "Experimental Strategy" section select "Tissue slide". (Tissue slide represent FS samples and diagnostic slide represent FFPE samples)
- All the above three selections were chosen from the left panel while the "Files" tap was open. Now switch to the "Cases" tap. 
- From the "Primary site," you are able to select the organs. In this study, we chose 10 organs that were not widely used in the other publicly available datasets. We chose the adrenal gland, larynx, lymph nodes, mediastinum, pancreas, pleura, skin, testes, thymus, and thyroid gland. 
- For each organ, we selected 3 WSIs at 40x magnification. A senior biologist at the Medical University of Vienna helped us with the WSI selection. The full description of the selected WSIs with meta data such as gender, sex, etc can be found in the repository files called "Selected_WSIs.xlsx". 

## WSI patch extraction

## Manual annotation with ImageJ

## Acknowledgements
This work was supported by the Austrian Research Promotion Agency (FFG), No. 872636 and the Kaggle open data research grant.




