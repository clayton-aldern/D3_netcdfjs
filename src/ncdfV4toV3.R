library(ncdf4)
library(RColorBrewer)

setwd("~/Developer/gristy/drought-page")

i <- nc_open("cmorph_spi_gamma_30_day_latest.nc")

lat <- ncdim_def("lat",
                 "degrees_north",
                 ncvar_get(i,"lat"))
lon <- ncdim_def("lon",
                 "degrees_east",
                 ncvar_get(i,"lon"))
time <- ncdim_def("time",
                  "seconds since 1970-01-01",
                  ncvar_get(i,"time"))
spi_gamma_30_day <- ncvar_def("spi_gamma_30_day",
                              "",
                              dim=list(lat,lon,time),
                              longname="Standardized Precipitation Index (Gamma), 30-day")
spi <- ncvar_get(i,"spi_gamma_30_day")
# spi[is.na(spi)] <- 0

o <- nc_create("spi.nc", spi_gamma_30_day)
ncvar_put(o, "spi_gamma_30_day", spi)
nc_close(i)
nc_close(o)
