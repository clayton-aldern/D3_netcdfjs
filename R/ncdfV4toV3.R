library(here)
library(ncdf4)
library(OpenImageR)

fname <- "cmorph_spi_gamma_90_day_latest.nc"
url <- paste0("https://www.ncei.noaa.gov/pub/data/nidis/test/cmorph/",
              fname)
download.file(url, fname)
i <- nc_open(fname)

# lon data are shifted 180º relative to reader default in D3_netcdfjs notebook,
# but we'll do that transformation in Observable
lon <- ncdim_def("lon",
                 "degrees_east",
                 seq(-179.5,179.5,1)) #downsampled version
                 # ncvar_get(i,"lon"))

# for lat data, we'll ultimately pad with zeros since the file only goes to ±60º,
# but instantiate the whole dimension
lat <- ncdim_def("lat",
                 "degrees_north",
                 seq(-89.5,89.5,1)) #downsampled version
                 # ncvar_get(i,"lat"))

time <- ncdim_def("time",
                  "seconds since 1970-01-01",
                  ncvar_get(i,"time"))

spi_gamma_90_day <- ncvar_def("spi_gamma_90_day",
                              "",
                              dim=list(lon,lat,time),
                              longname="Standardized Precipitation Index (Gamma), 90-day")
spi <- ncvar_get(i,"spi_gamma_90_day")
spi[is.na(spi)] <- 0
spi <- cbind(matrix(0,1440,120),spi,matrix(0,1440,120)) # there's the zero-pad

# convert SPI to drought severity ratings
# source: https://www.weather.gov/riw/drought_index
spi[spi >= -.4] <- 0
spi[spi <= -0.5 & spi > -0.8] <- 0
spi[spi <= -0.8 & spi > -1.3] <- 1
spi[spi <= -1.3 & spi > -1.6] <- 2
spi[spi <= -1.6 & spi > -2] <- 3
spi[spi <= -2] <- 4

# downsample original .nc
spiDown <- resizeImage(spi,
                       360,
                       180,
                       method = "nearest",
                       normalize_pixels = FALSE)

# save new .nc
o <- nc_create("spiDown.nc", spi_gamma_90_day)
ncvar_put(o, "spi_gamma_90_day", spiDown)
nc_close(i)
nc_close(o)
