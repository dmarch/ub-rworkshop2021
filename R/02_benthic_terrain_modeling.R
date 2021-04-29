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

# resample to a coarser resolution (0.042 x 0.042 degrees)
bathy_ag <- aggregate(bat, fact = 20, fun = mean)

# prepare raster to calculate distance
bathy_d <- bathy_ag
bathy_d[is.na(bathy_d[])] <- 10000 
bathy_d[bathy_d < 10000] <- NA 

# distance
dist2coast <- distance(bathy_d)  # calculate distance
dist2coast <- dist2coast / 1000  # convert to km
dist2coast[dist2coast == 0] <- NA  # set 0 values to NA
plot(dist2coast)



#---------------------------------------------------------------
# Part 4: Distance metrics: distance to colony
#---------------------------------------------------------------

library(gdistance)

# Colony location
CalaMorell <- c(3.86877, 40.055872)

# create ocean mask using the bathymetry
mask <- bat/bat

# change to a coarser resolution
mask_ag <- aggregate(mask, fact = 10)

# create surface
tr1 <- transition(mask_ag, transitionFunction=mean, directions=16)
tr1C <- geoCorrection(tr1)

# calculate distance to colony
dist2col <- accCost(tr1C, CalaMorell)
dist2col[is.infinite(dist2col)] <- NA
plot(dist2col)




#----------------------------------------------
# Part 5: Export raster data
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
# Part 6: Extract raster data for animal track
#----------------------------------------------

# import tracking data
data <- read.csv("data/L1_locations_6002105.csv")
head(data)

# Use extract function
data$depth <- raster::extract(bat, cbind(data$lon, data$lat))
head(data$depth)
summary(data$depth)
hist(data$depth)

# Exercise:
# - Extract slope and other metrics
# - Plot time series of extracted variables

