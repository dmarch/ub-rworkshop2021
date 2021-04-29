################################################################################
#
# Title: Benthic Terrain Modeling
# Course: Using R to work with marine spatial data
#
# Author: David March
# Email: dmarch@ub.edu
# Last revision: 2021/04/29
#
# Keywords: R, marine, data, GIS, map, raster, bathymetry, terrain
#
# Copyright 2016 SOCIB
# The script is distributed under the terms of the GNUv3 General Public License
#
################################################################################

# load libraries
library(raster)
library(leaflet)
library(rgdal)
library(RColorBrewer)
library(rasterVis)
library(rgl)
library(ggplot2)
library(tidyr)

#----------------------------------------------
# Part 1: Import raster data
#----------------------------------------------

# Import bathymetry
# see download-emodnet.R for details on how to download this data
bat <- raster("data/emodnet-mean-westmed.tif")

# Inspect raster data
class(bat)
bat
hist(bat)

# Plot raster data

# base
plot(bat) 

# rasterVis
rasterVis::levelplot(
  bat,
  margin = TRUE, contour = T, main = "Bathymetry (m) - EMODnet",
  par.settings = rasterVis::rasterTheme(region = brewer.pal("Blues", n = 9))
)

# 3d plot
myPal <- colorRampPalette(brewer.pal(9, 'Blues'), alpha=TRUE)  # palette
plot3D(bat*(-1), col=myPal, rev=TRUE, specular="black")  # plot 3d with rgl



#----------------------------------------------
# Part 2: Bathymetric Terrain Modeling
#----------------------------------------------

# Calculate terrain characteristic from bathymetry
slope <- terrain(bat, opt=c("slope"), unit='degrees')

# Exercise:
# 1. Inspect derived data
# 2. Explore other metrics that can be derived from terrain()



#----------------------------------------------
# Part 3: Manipulate raster data
#----------------------------------------------

# transform 0 to NA
bat[bat == 0] <- NA

# transform positive values to negative
bat_neg <- bat * (-1)



#----------------------------------------------
# Part 3: Export raster data
#----------------------------------------------

# create output directory
out_dir <- "output"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# export your data in multiple formats
writeRaster(slope, filename="output/slope.grd", overwrite=TRUE)  # save binary file for slope
writeRaster(slope, filename="output/slope.tif", overwrite=TRUE)  # save binary file for slope
writeRaster(slope, filename="output/slope.nc", overwrite=TRUE)  # save binary file for slope

KML(bat, "output/bat.kml", col = myPal(100), overwrite = TRUE)  # save KML file for bathymetry



#----------------------------------------------
# Part 4: Extract raster data for animal track
#----------------------------------------------

# import tracking data
data <- read.csv("data/L1_locations_6002105.csv")
head(data)

# Use extract function
data$depth <- raster::extract(bat, cbind(data$lon, data$lat))
head(data$depth)
summary(data$depth)
hist(data$depth)

# Exercise: Extract slope

