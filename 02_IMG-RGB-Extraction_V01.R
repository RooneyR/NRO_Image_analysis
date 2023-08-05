# ~~~~~~~~~~~~~~~~~~~~~~~~~ NRO Senescence project ~~~~~~~~~~~~~~~~~~~~~~~~~
## ~~~~~~~~~~~~~~~~~~~ Leaf Image RGB Extraction ~~~~~~~~~~~~~~~~~~~~~~~~~~~
### ~~~~~~~~~~~~~~~~~~~ Created By: Rebecca Rooney ~~~~~~~~~~~~~~~~~~~~~~~~~
#### ~~~~~~~~~~~~~~~~~~~ Last Updated: 2023/06/23 ~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose: Take color corrected images and pull RGB values ~~~~~~~~~~~~~~~~~
# ~~~~~~~~~ Save a summary of mean  pixel intensity, count, percent color ~~
# ~~~~~~~~~   and other derived metrics as a csv file ~~~~~~~~~~~~~~~~~~~~~~

# Packages:
packages <- c("tidyverse", "magick", "OpenImageR", "scales", "imager", "tiff", "png")
lapply(packages, require, character.only = TRUE)

#Packages not loaded:
#ImaginR (not avail for current Ver of R)


# ~~~~~~~~ PART 1: COLOR CORRECTING THE IMAGES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## OPTION 1:
### ~Create a ICC (color correcting matrix) using Color Checker Calibration Software
### ~Assign ICC to images in Adobe Photoshop, record action to batch process

## OPTION 2: IN DEVELOPMENT


# ~~~~~~~~ PART 2: REMOVING THE IMAGE BACKGROUND ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## See file: 01-IMG-Background-Removal_V01.R to complete this step.



# ~~~~~~~~ PART 3: EXTRACT RGB COLOR VALUES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## Get list of images w/o background
list_photos <- list.files(
  path = "filepath",
  pattern = NULL, all.files = FALSE, full.names = F, ignore.case = TRUE
)

## OPTIONAL: Convert TIF to PNG
for (i in 1:length(list_photos)) {
  img <- image_read(list_photos[i])
  image_write(img, path = str_c(substr(list_photos[i], 1, 8), "-PRC2-", i, ".png"), format = "png")
}


for (i in 1:length(list_photos)) {
  load_pic <- load.image(list_photos[i])                    # loading the file as an image
  pic_df <- as.data.frame(load_pic)                         # converting image to a data frame
  pic_df0 <- filter(pic_df, cc != 4) %>%                    # Remove the transparent cc
    mutate(channel = factor(cc, labels = c("R", "G", "B"))) # Reclassifying cc values to channels
  pic_df1 <- subset(pic_df0, select = -cc)%>%               #Create columns per color channel
    group_by(channel)%>%
    mutate(rn = row_number()) %>% 
    pivot_wider(names_from = channel, values_from = value) %>% 
    select(-rn)
  pic_dfRGB <- pic_df1%>% 
    mutate(across(c("R","G","B"), 
                  ~ifelse(R-G > 0.1 & R-G < 0.17 & G-B > 0.1 & G-B < 0.17, 0, .))) #Exclude necrotic tissue
  pic_sum_RGB <- filter(pic_dfRGB, R > 0.01 & R < 0.98 & G > 0.01 & G < 0.98 & B > 0.01 & B < 0.98)%>% #Exclude black (0)/white(1) pixels
    summarise(
      mean_val_R = mean(R),                #mean intensity value in the Red channel
      R_count = length(which(R-G > 0 )),   #Number of predominately red pixels 
      mean_val_G = mean(G),                #mean intensity value in the Green channel
      G_count = length(which(G-R > 0)),    #Number of predominately green pixels
      mean_val_B = mean(B),                #mean intensity value in the Blue channel
      Total_pixels = n(),                  #Total number of pixels that are leaf tissue
      Perc_R = R_count/Total_pixels*100,   #Percent of leaf that's red
      Perc_G = G_count/Total_pixels*100,   #Percent of leaf that's green
      S_red = (mean_val_R / sum(mean_val_R + mean_val_G + mean_val_B)),   #Metric to asses relative intensity value per channel
      S_green = (mean_val_G / sum(mean_val_R + mean_val_G + mean_val_B)),
      S_blue = (mean_val_B / sum(mean_val_R + mean_val_G + mean_val_B)),
      RG_ratio = ifelse((mean_val_G*G_count) != 0,                         #Ratio of R to G tissue by the product of area and intensity
                        ((mean_val_R*R_count) / (mean_val_G*G_count)),     #if else to prevent an undefined scenario
                        ((mean_val_R*R_count) / (mean_val_G*G_count+0.1))),
      Dom_CC = case_when(                  #Binning ratio as red/green factors
        (RG_ratio >= 1) ~ "Red",
        (RG_ratio < 1) ~ "Green",
      )
    )
  pic_sum <- mutate(pic_sum_RGB, Pr_Img_name = list_photos[i], Image_Name = str_c(substr(list_photos[i], 1, 8))) # summarizing image values by channel
  Pic_output <- write_csv(pic_sum, append = T, "Fall2021_Img_Summary_final.csv") # creating an csv of summary info
}


