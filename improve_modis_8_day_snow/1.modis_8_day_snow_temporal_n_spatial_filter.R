# Title: MODIS 8-day snow cloud removal using temporal and spatial filters
# Writer: amrit THAPA (amrit.thapa@icimod.org)
# Affiliation:  International Centre for Integrated Mountain Development (ICIMOD,http://www.icimod.org/)
# Date; 2019-01-01
# Disclamier: Use at your own risk
# NOTE: 1) You should have at least 5 images in your input folder
#       2)if you want to run the code again and again, close RStudio and delete all the folder previously created

#clean the working environment of RStudio
rm(list=ls())

# Load required library. Make sure that following packages are already installed.
library(raster)
library(varhandle)
library(fs)

# for_aqua_replace MOD10A2 by MYD10A2 and vice-versa

# folder where one has input data (only .tif). You just need to change the following line(line no 20) to run this code.
input_dir=".../MOD10A2"

setwd(input_dir)

#lsit .tif images from input directory
list_modis_MOD10A2=list.files(getwd(),pattern=".tif")


dir.create("temporal_filter_MOD10A2") 
#Warning message appears if you run second time, ignore the message

#location for output
output_dir_temporal_MOD10A2="./temporal_filter_MOD10A2/"

#temporal_filter: maximum five images
for (i in 3:(length(list_modis_MOD10A2)-2)){
  
  t0=raster(list_modis_MOD10A2[i-2])
  t1=raster(list_modis_MOD10A2[i-1])
  t2=raster(list_modis_MOD10A2[i])
  t3=raster(list_modis_MOD10A2[i+1])
  t4=raster(list_modis_MOD10A2[i+2])
  
  idx_SCS<- values(t2)==50 & values(t3)==200 & values(t1) == 200
  values(t2)[idx_SCS]<-200
  
  idx_LCL<- values(t2)==50 & values(t3)==25 & values(t1) == 25
  values(t2)[idx_LCL]<-25
  
  idx_SCL<- values(t2)==50 & values(t3)==25 & values(t1) == 200
  values(t2)[idx_SCL]<-25
  
  idx_LCS<- values(t2)==50 & values(t3)==200 & values(t1) == 25
  values(t2)[idx_LCS]<-200
  
  idx_CCL<- values(t2)==50 & values(t3)==25 & values(t1) == 50
  values(t2)[idx_CCL]<-25
  
  idx_CCS<- values(t2)==50 & values(t3)==200 & values(t1) == 50
  values(t2)[idx_CCS]<-200
  
  idx_LCC<- values(t2)==50 & values(t3)==50 & values(t1) == 25
  values(t2)[idx_LCC]<-25
  
  idx_SCC<- values(t2)==50 & values(t3)==50 & values(t1) == 200
  values(t2)[idx_SCC]<-200
  
  idx_CCC<- values(t2)==50 & values(t3)==50 & values(t1) == 50
  values(t2)[idx_CCC]<-values(t4)[idx_CCC]
  
  idx_CCCC<-values(t2)==50
  values(t2)[idx_CCCC]<-values(t0)[idx_CCCC]
  
  writeRaster(t2,filename=paste0(output_dir_temporal_MOD10A2,"t_5img_",list_modis_MOD10A2[i]),format="GTiff",overwrite=T)
  print(i)
}

#Spatial filter: 1st time

rm.all.but(c("input_dir"))
#remove all variables in workspace except input path

set.seed(123) 
#for creating simulations or random objects that can be reproduced

library(raster)


setwd(paste0(input_dir,"/temporal_filter_MOD10A2"))
list_modis_MOD10A2_after_temporal=list.files(getwd(),pattern=".tif")

dir.create("spatial_filter_1_MOD10A2")
output_dir_spatial1_MOD10A2="./spatial_filter_1_MOD10A2/"

for (i in 1:length(list_modis_MOD10A2_after_temporal))
{
  snow_for_spatial=raster(list_modis_MOD10A2_after_temporal[i])
  snow_for_spatial[snow_for_spatial == 50]<-NA
  s_filter <- focal(snow_for_spatial, w=matrix(1,3,3), fun=modal, na.rm=TRUE, NAonly=TRUE, pad=TRUE)
  # NAonly (logical). If TRUE, only cell values that are NA are replaced with the computed focal values
  # na.rm (logical). If TRUE, NA will be removed from focal computations. The result will only be NA if all focal cells are NA.
  # pad (logical). If TRUE, additional 'virtual' rows and columns are padded to x such that there are no edge effects. This can be useful when a function needs to have access to the central cell of the filter
  
  s_filter[is.na(s_filter)]<-50
  writeRaster(s_filter,filename=paste0(output_dir_spatial1_MOD10A2,"s_",list_modis_MOD10A2_after_temporal[i]),format="GTiff",overwrite=T)
  print(i)
}

#Spatial filter: 2nd time
rm.all.but(c("input_dir"))
set.seed(456)

library(raster)
setwd(paste0(input_dir,"/temporal_filter_MOD10A2/spatial_filter_1_MOD10A2"))
list_modis_MOD10A2_after_spatial2=list.files(getwd(),pattern=".tif")

dir.create("spatial_filter_2_MOD10A2")
output_dir_spatial2_MOD10A2="./spatial_filter_2_MOD10A2/"

for (i in 1:length(list_modis_MOD10A2_after_spatial2))
{
  snow_for_spatial=raster(list_modis_MOD10A2_after_spatial2[i])
  snow_for_spatial[snow_for_spatial == 50]<-NA
  s_filter <- focal(snow_for_spatial, w=matrix(1,3,3), fun=modal, na.rm=TRUE, NAonly=TRUE, pad=TRUE)
  s_filter[is.na(s_filter)]<-50
  writeRaster(s_filter,filename=paste0(output_dir_spatial2_MOD10A2,"s_",list_modis_MOD10A2_after_spatial2[i]),format="GTiff",overwrite=T)
  print(i)
}

#Spatial filter: 3rd time
rm.all.but(c("input_dir"))
set.seed(789)

library(raster)
setwd(paste0(input_dir,"/temporal_filter_MOD10A2/spatial_filter_1_MOD10A2/spatial_filter_2_MOD10A2"))
list_modis_MOD10A2_after_spatial3=list.files(getwd(),pattern=".tif")

dir.create("spatial_filter_3_MOD10A2")
output_dir_spatial3_MOD10A2="./spatial_filter_3_MOD10A2/"

for (i in 1:length(list_modis_MOD10A2_after_spatial3))
{
  snow_for_spatial=raster(list_modis_MOD10A2_after_spatial3[i])
  snow_for_spatial[snow_for_spatial == 50]<-NA
  s_filter <- focal(snow_for_spatial, w=matrix(1,3,3), fun=modal, na.rm=TRUE, NAonly=TRUE, pad=TRUE)
  s_filter[is.na(s_filter)]<-50
  writeRaster(s_filter,filename=paste0(output_dir_spatial3_MOD10A2,"s_",list_modis_MOD10A2_after_spatial3[i]),format="GTiff",overwrite=T)
  print(i)
}

######################### THE END, OPEN 2.modis_8_day_snow_combine file, change line no 12 and run the code











