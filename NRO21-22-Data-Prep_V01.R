#~~~~~~~~~~~~~~~~~~~~~~~~~ NRO Senescence project ~~~~~~~~~~~~~~~~~~~~~~~~~ 
##~~~~~~~~~~~~~~~~~~~ Data QA/QC, joins, and formatting ~~~~~~~~~~~~~~~~~~~
###~~~~~~~~~~~~~~~~~~~ Created By: Rebecca Rooney ~~~~~~~~~~~~~~~~~~~~~~~~~
####~~~~~~~~~~~~~~~~~~~ Last Updated: 2023/06/23 ~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose: Take csv versions of raw data and format data (e.g., dates, time, etc.)
#~~~~~~~~~ Join collected data with processed image data RGB outputs ~~~~~~
#~~~~~~~~~ Append datasheets with derived calculations ~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~ Combine multiple columns via melting and naming ~~~~~~~~~~~~~~~~
#~~~~~~~~~ Prepare summaries from raw data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Packages:
library(tidyverse)
library(lubridate)
library(reshape2)

# ~~~~~~~~ ENVIRONMENTAL DATA 2021/2022 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Read csv files and mutate to set Date in the format of M/D/Y and time in H:M

### Sun rise and set times over the course of the sampling season (Aug-Oct) ~~~~

sundata <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Masters_NRO_Analyses/Data_NRO_all/Processed/Combined21-22 NRO/Environmental Data/Fall22-sunriseset.csv")

sundata <- mutate(sundata, Date = as.Date(Date, format = "%m/%d/%y"), 
                   SunR = as.POSIXct(Sunrise, format = "%H:%M"), 
                   SunS = as.POSIXct(Sunset, format = "%H:%M"))

### Mean Temperature and Precipitation over the course of the sampling season (Aug-Oct)

temp_precip <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Masters_NRO_Analyses/Data_NRO_all/Processed/Combined21-22 NRO/Environmental Data/NRO21-22-TempPrecip.csv") 

temp_precip <- mutate(temp_precip, Date = as.Date(Date, format = "%m/%d/%y"))


# ~~~~~~~~ 2022 NRO DATA SHEET  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Read 2022 csv and mutate the following:
## ~Set Date in the format of M/D/Y
## ~AC_mg.cm2 --> Converting Anthocyanin Conc. to mg/cm^2
## ~ChlAB_ratio --> Determine the ratio of Chla to Chlb
## ~CN_ratioAM/PM --> Determine the ratio of leaf carbon to nitrogen
## ~C_export --> Corrected Carbon Export estimate following Terry and Mortimer's
### equation for handling negative Anet measurements 
## ~NRO22_Cxp_carbon --> Opt. Calculating carbon export using leaf carbon values

NRO22_data <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Masters_NRO_Analyses/Data_NRO_all/Processed/2022 NRO/Fall_data_ALL.csv")  


NRO22_data <- mutate(NRO22_data, 
                  AC.CC_ratio = Mean_AC_mg.g/Mean_CHLa_ug.mg, 
                  AC_mg.cm2 = Mean_AC_mg.g*(1/SLA_cm2.g), 
                  ChlAB_ratio = Mean_CHLa_ug.mg/Mean_CHLb_ug.mg, 
                  Date = as.Date(Date_Collected, format = "%m/%d/%y"), 
                  CN_ratioAM = ((Perc_C_AM/100)/CN_AMmass_mg)/((Perc_N_AM/100)/CN_AMmass_mg), 
                  CN_ratioPM = ((Perc_C_PM/100)/CN_PMmass_mg)/((Perc_N_PM/100)/CN_PMmass_mg),
                  C_export = case_when(
                    (CDiffDivT <= A_mean) ~ (A_mean-CDiffDivT),
                    (A_mean < 0) ~ (CDiffDivT-A_mean),
                    (A_mean > 0 & CDiffDivT > A_mean) ~ (A_mean-CDiffDivT)
                  )
              )

## CHECKING CXP BASED ON CARBON CONTENT, DON'T NEED
NRO22_cxp_carbon <- mutate(NRO22_data, 
                    Cxp_CPM_mass = (DrMass_PM*(Perc_C_PM/100)/1000/12*1000000)/(0.0000785398163397*6), 
                    Cxp_CAM_mass = (DrMass_AM*(Perc_C_AM/100)/1000/12*1000000)/(0.0000785398163397*6), 
                    Cxp_carbon = A_mean - ((Cxp_CPM_mass-Cxp_CAM_mass)/Delta_T_S)
                  ) 


# Comb_mass <- melt(CNdata3, id.vars = 'Date', measure.vars = c("DrMass_AM","DrMass_PM"))
# Comb_Anet <- melt(CNdata3, id.vars = 'Date', measure.vars = c("A_AM", "A_PM"))


# ~~~~~~~~ 2022 NRO IMAGE RGB SUMMARY DATA  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


NRO22_img_CCM <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Masters_NRO_Analyses/Data_NRO_all/Processed/2022 NRO/Fall2022_Img_Summary_CORR.csv")

## Join the Image and sample datasheets, retaining all columns
NRO22_data_RGB <- full_join(y = NRO22_img_CCM, x = NRO22_data) 


# ~~~~~~~~ 2022 NRO SUMMARIZED DATA  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Summary of Anet measurements grouped by date collected
## ~AM_mean/PM_mean --> Anet measured in the morning or afternoon
## ~A_mean --> The average Anet of the combined AM and PM
## ~A_std --> The standard deviation for A_mean

NRO22_Anet_sum <- filter(NRO22_data, Measurement_Type != "CALLOSE") %>%
  group_by(Date) %>% 
  summarise( 
    AM_mean = mean(A_AM), PM_mean = mean(A_PM),
    A_mean = mean(c(AM_MEAN, PM_MEAN)),
    A_std = std(c(AM_std, PM_std)),
    count = n()
  )

#===============================================================================
#===============================================================================
#===============================================================================



# ~~~~~~~~ 2021 NRO DATA SHEET  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Read 2021 csv and mutate the following:


NRO21_data <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Fall-Data-Sheets/Old Data Sheet Versions/FallCampaign_21.csv")


# ~~~~~~~~ 2021 NRO IMAGE RGB SUMMARY DATA  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


NRO21_img_CCM <- read.csv("/Users/rebeccarooney/Desktop/MASTERS/Research/Senescence Study/Masters_NRO_Analyses/Data_NRO_all/Processed/2021 NRO/Fall2021_Img_Summary.csv")

## Join the Image and sample datasheets, retaining all columns
NRO21_data_RGB <- full_join(y = NRO21_img_CCM, x = NRO21_data) 

