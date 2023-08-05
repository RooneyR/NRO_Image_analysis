# ~~~~~~~~~~~~~~~~~~~~~~~~~ NRO Senescence project ~~~~~~~~~~~~~~~~~~~
## ~~~~~~~~~~~~~~~~~~~ Leaf Image Background Removal ~~~~~~~~~~~~~~~~~
### ~~~~~~~~~~~~~~~~~~~ Created By: Rebecca Rooney ~~~~~~~~~~~~~~~~~~~
#### ~~~~~~~~~~~~~~~~~~~ Last Updated: 2023/06/23 ~~~~~~~~~~~~~~~~~~~~
# Purpose: Take color corrected images and remove background area ~~~~
# ~~~~~~~~~ Save images to a new folder with the image name ~~~~~~~~~~

# Packages:
library(tidyverse)
library(magick)
library(OpenImageR)
library(imager)
library(ImaginR)
library(png)


# ~~~~~~~~ PART 1: COLOR CORRECTING THE IMAGES ~~~~~~~~~~~~~~~~~~~

## OPTION 1:
## ~Create a ICC (color correcting matrix)
##  using Color Checker Calibration Software
## ~Assign ICC to images in Adobe Photoshop, record action to batch process

## OPTION 2: IN DEVELOPMENT


# ~~~~~~~~ PART 2: REMOVING THE IMAGE BACKGROUND ~~~~~~~~~~~~~~~~~

## Get the list of all images
list_photos <- list.files(
  path = "filepath",
  pattern = NULL, all.files = FALSE, full.names = FALSE, ignore.case = TRUE
)

## IMPORTANT NOTE:
## This loop requires a single folder of images that contains the color image
## and a matching B&W image. I made the B&W images in ImageJ while measuring
## leaf area. The list should be ordered so these two images are paired, with
## first image being the B&W image.The loop below will transform and overlay
## the paired images such that the final result is a color image of a leaf with
## no background. Images must be .PNG which supports the alpha color channel.


for (i in 1:length(list_photos)) { # for loop loading each image
  if (i %% 2 == 1) { # Odd and even images are paired, this will skip even numbered images (aka keeps pairs together)
    pic_bw <- image_read(list_photos[i]) # read the BW image
    pic_bw_trans <- image_transparent(pic_bw, color = "black", fuzz = 0) # black leaf area becomes transparent
    pic_color <- image_read(list_photos[i + 1]) # read the color image
    step1_grpimg <- c(pic_color, pic_bw_trans) # couples the 2 images, the last image listed will be on top in next step
    step2_flatten <- image_flatten(step1_grpimg) # Combines the 2 images in an overlay and flattens to 1 image
    step3_transp <- image_transparent(step2_flatten, color = "white", fuzz = 0) # Removes background around leaf
    image_write(step3_transp,
                path = str_c(substr(list_photos[i], 1, 8), "-PRC", i, ".png"),
                format = "png") # Saves final image
  }
}
