#~~~~~~~~~~~~~~~~~~~~~~~~~ NRO Senescence project ~~~~~~~~~~~~~~~~~~~~~~~~~ 
##~~~~~~~~~~~~~~~~~~~ Leaf Image RGB Extraction ~~~~~~~~~~~~~~~~~~~~~~~
###~~~~~~~~~~~~~~~~~~~ Created By: Rebecca Rooney ~~~~~~~~~~~~~~~~~~~~~~~~~
####~~~~~~~~~~~~~~~~~~~ Last Updated: 2023/06/23 ~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose: Take color corrected images and pull RGB values ~~~~~~~~~~~~~~~~
#~~~~~~~~~ Save a summary of mean and median pixel intensity, count ~~~~~~~
#~~~~~~~~~ stdev., and other derived metrics as a csv file ~~~~~~~~~~~~~~~~

#Packages:
library(tidyverse)
library(magick)
library(OpenImageR)
library(scales)
library(imager)  
library(raster)
library(ImaginR)
library(viridis)
library(tiff)
library(png)


#~~~~~~~~ PART 1: COLOR CORRECTING THE IMAGES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## OPTION 1:
### ~Create a ICC (color correcting matrix) using Color Checker Calibration Software
### ~Assign ICC to images in Adobe Photoshop, record action to batch process

## OPTION 2: IN DEVELOPMENT


#~~~~~~~~ PART 2: REMOVING THE IMAGE BACKGROUND ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## See file: 01-IMG-Background-Removal_V01.R to complete this step.



#~~~~~~~~ PART 3: EXTRACT RGB COLOR VALUES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## Get list of images w/o background
list_photos = list.files(path = "/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Photos/Fall 2021 Leaf Photos/Step3", 
                   pattern = NULL, all.files	= FALSE, full.names = F, ignore.case	= TRUE)

## OPTIONAL: Convert TIF to PNG 
for(i in 1:length(list_photos)) { 
  img <- image_read(list_photos[i])
    image_write(img, path = str_c(substr(list_photos[i], 1, 8), "-PRC2-", i, '.png'), format = "png")
}



for(i in 1:length(list_photos)) { 
  load_pic <- load.image(list_photos[i]) #loading the file as an image
    pic_df <- as.data.frame(load_pic) #converting image to a data frame
      pic_df1 <-filter(pic_df, cc != 4)%>%
                  mutate(channel=factor(cc,labels=c('R','G','B'))
                 ) #Reclassifying cc values to channels
        pic_sumR <- filter(pic_df1, value > 0 & value < 0.95, cc == 1)%>% 
            summarise(
                index = i,
                mean_val_R = mean(value), 
                median_val_R = mean(value),
                STD_val_R = mean(value),
                count_R = n()
            )
        pic_sumG <- filter(pic_df1, value > 0 & value < 0.95, cc == 2)%>% 
            summarise(
                index = i,
                mean_val_G = mean(value),
                median_val_G = mean(value),
                STD_val_G = mean(value),
                count_G = n()
            )
        pic_sumB <- filter(pic_df1, value > 0 & value < 0.95, cc == 3)%>% 
            summarise(
                index = i,
                mean_val_B = mean(value),
                median_val_B = mean(value),
                STD_val_B = mean(value),
                count_B = n()
            )
        pic_sum_RG <- left_join(pic_sumR, pic_sumG)
        pic_sum_RGB <- left_join(pic_sum_RG, pic_sumB)
        pic_sum_all <- pic_sum_RGB %>%
            mutate(
                S_red = (mean_val_R/sum(mean_val_R+mean_val_G+mean_val_B)),
                S_green = (mean_val_G/sum(mean_val_R+mean_val_G+mean_val_B)),
                S_blue = (mean_val_B/sum(mean_val_R+mean_val_G+mean_val_B)),
                RG_ratio = S_red/S_green,
                Dom_CC = case_when(
                  (S_red > S_green & S_red > S_blue) ~ "Red",
                  (S_red < S_green & S_green > S_blue) ~ "Green",
                  (S_blue > S_green & S_red < S_blue) ~ "Blue"
              )
            )
        pic_sum1 <- mutate(pic_sum_all, Pr_Img_name = list_photos[i], Image_Name = str_c(substr(list_photos[i], 1, 8))) #summarizing image values by channel
        Pic_output <- write_csv(pic_sum1, append = T, "Fall2022_Img_Summary_CORR.csv") #creating an csv of summary info
}

  

#================================  END  ========================================




