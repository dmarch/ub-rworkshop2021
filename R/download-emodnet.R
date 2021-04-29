# donwload-emodnet
# This script downloads EMODnet bathymetry


# Define a function to read in raster data from the EMODnet bathymetry WCS
# Adapted from https://www.emodnet.eu/conference/opensealab/sites/opensealab.eu/files/public/2019/data/OSLII_R_Tutorial_EMODnet.html
getbathymetry <- function(name = "emodnet:mean", resolution = "0.2km", xmin = 15, xmax = 20.5, ymin = 30, ymax = 32.5) {
  bbox <- paste(xmin, ymin, xmax, ymax, sep = ",")
  
  con <- paste("https://ows.emodnet-bathymetry.eu/wcs?service=wcs&version=1.0.0&request=getcoverage&coverage=", name, "&crs=EPSG:4326&BBOX=", bbox, "&format=image/tiff&interpolation=nearest&resx=0.00208333&resy=0.00208333", sep = "")
  
  print(con)
  
  stop
  nomfich <- paste(name, "img.tiff", sep = "_")
  nomfich <- tempfile(nomfich)
  downloader::download(con, nomfich, quiet = TRUE, mode = "wb")
  img <- raster::raster(nomfich)
  img[img == 0] <- NA
  img[img < 0] <- 0
  names(img) <- paste(name)
  return(img)
}


# Download bathymetry
bathy_img <- getbathymetry(name = "emodnet:mean", resolution = "0.2km",
                           xmin = -1, xmax = 6, ymin = 37, ymax = 43)

# Save bathymetry as GeoTiff
writeRaster(bathy_img, "data/emodnet-mean-westmed.tif")
