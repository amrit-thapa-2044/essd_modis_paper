# Title: Combine AQUA and TERRA images after applying tempotal and spatial filters
# Writer: amrit THAPA (amrit.thapa@icimod.org)
# Affiliation:  International Centre for Integrated Mountain Development (ICIMOD,http://www.icimod.org/)
# Date; 2019-01-01
# Disclamier: Use at your own risk
# Before proceeding make sure that you have run the script: (1.modis_8_day_snow_temporal_n_spatial_filter.R)

rm(list=ls())
library(raster)

#set the location of modis_8day_snow folder.You just need to change the following line(line no 12) to run this code.
input_dir="C:/Users/amthapa/Desktop/modis_8day_snow/"

input_dir_aqua=paste0(input_dir,"MYD10A2")
input_dir_terra=paste0(input_dir,"MOD10A2")

# Among following two lines, one should be for AQUA and other for TERRA. 
input_terra_after_3s=paste0(input_dir_terra,"/temporal_filter_MOD10A2/spatial_filter_1_MOD10A2/spatial_filter_2_MOD10A2/spatial_filter_3_MOD10A2/")
input_aqua_after_3s=paste0(input_dir_aqua,"/temporal_filter_MYD10A2/spatial_filter_1_MYD10A2/spatial_filter_2_MYD10A2/spatial_filter_3_MYD10A2/")

snow_aqua=list.files(input_aqua_after_3s,pattern=".tif")
snow_terra=list.files(input_terra_after_3s,pattern=".tif")

#make sure that package "stringr" is already installed
library(stringr)

#manually check whether terra has corresponding image in aqua and vice-versa
# if not, the extra images have to be deleted in both AQUA and TERRA
# the following date/doy help to check the date of images
doy_terra=as.numeric(str_sub(snow_terra,-11,-5));head(doy_terra)
doy_aqua=as.numeric(str_sub(snow_aqua,-11,-5));head(doy_aqua)

new_filename=paste0("AQUA_TERRA_8day_combined_5t_3s_",doy_aqua,".tif");head(new_filename)
dir.create(paste0(input_dir,"/combined_product_after_5t_3s"))

outpath_dir_combined=paste0(input_dir,"combined_product_after_5t_3s/")

for(i in 1:length(doy_aqua))
{  
  aqua=raster(paste0(input_aqua_after_3s,snow_aqua[i]))
  terra=raster(paste0(input_terra_after_3s,snow_terra[i]))
  
  aqua[aqua==25]<-225
  terra[terra==25]<-225
  
  combined_aqua_terra=max(aqua,terra)
  combined_aqua_terra[combined_aqua_terra==225]<-25
  
  writeRaster(combined_aqua_terra,filename=paste0(outpath_dir_combined,new_filename[i]),format="GTiff",overwrite=T)
  print(i)
}

######### THE END
# you may visualize the final output in any GIS software.Final images are inside folder "combined_product_after_5t_3s"