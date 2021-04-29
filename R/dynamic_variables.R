

library(lubridate)
library(ncdf4)

# import tracking data
data <- read.csv("data/L1_locations_6002105.csv")
data$date <- parse_date_time(data$date, "Ymd HMS", tz="UTC")

# explore temporal and spatial range
range(data$date)
range(data$lon)
range(data$lat)

# import netCDF
nc <- nc_open("data/med00-cmcc-tem-an-fc-d_1619689725304.nc")
print(nc)
# Questions:
# how many dimensions?
# how many variables?
# what are their units?
# what is the format used for the time?

# import netCDF with raster
r <- raster("data/med00-cmcc-tem-an-fc-d_1619689725304.nc")
# Exercise: explore this dataset


# import multiple bands
s <- brick("data/med00-cmcc-tem-an-fc-d_1619689725304.nc")

# calculate average and SD
sst_mean <- mean(s)
sst_sd <- calc(s, sd)



# Exercise
# derive a new metric: temperature gradient
# temperature gradient can be defined using the slope previously


# Exercise
# download a NPP product


# transform time series from raster
time <- getZ(s)
time <- as.POSIXct(time*60, origin = "1900-01-01", tz = "UTC") 
days <- as.Date(time)
s <- setZ(s, z = days)

# prepare data for extraction
# use same temporal resolution (day)
data$day <- as.Date(data$date)

# create new extract function
extractTSR <- function(x, y, t){
  
  # get time from raster
  xtime <- raster::getZ(x)
  
  # match point time with raster
  # returns index from multilayer
  idx <- match(t, xtime)
  
  # extract data for all points from all layers
  ex <- raster::extract(x, y)
  
  # for each data point, select the data for idx
  dat <- ex[cbind(1:length(t), idx)]
  return(dat)
}

# extract data from Time Series Raster
data$sst <- extractTSR(x = s, y = cbind(data$lon, data$lat), t = data$day)
plot(data$date, data$sst, type="l")
