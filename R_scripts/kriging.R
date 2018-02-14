##### SETUP #####

library(raster)
library(gstat)

setwd("~/Desktop/HydroSatML/")

##### DATA IMPORT #####

# field coordinates
coords <- read.csv("data/sensor_coords/SCF_TierII_site_coords.csv")
coords_aes <- coords[1:12, 1:2]
# TODO: pull out coordinates for other fields; consider splitting out to list

# sample SMR raster file
smr <- raster("data/SMR/Aes/rz.mc_1592013.asc")



# plot SMR output
plot(smr, main="SMR output - AES", zlim=c(.17,.25))
points(coords_aes)
text(x=coords_aes[,1], y=coords_aes[,2], 1:12, cex=.75, pos=4)

# plot adjusted SMR after accounting for differences from monitored data
diff_raster <- raster("~/Desktop/HydroSatML/jupyter_notebooks/output.asc")/100
diff_raster <- raster("~/Desktop/HydroSatML/jupyter_notebooks/dog.txt")/100
plot(diff_raster)
adjusted_smr <- smr+diff_raster

plot(adjusted_smr, main="SMR output adjusted for diffs", zlim=c(.17,.25))
points(coords_aes)
text(x=coords_aes[,1], y=coords_aes[,2], 1:12, cex=.75, pos=4)

# plot diff raster
plot(diff_raster, main="diffs")
points(coords_aes)
text(x=coords_aes[,1], y=coords_aes[,2], 1:12, cex=.75, pos=4)

plot(adjusted_smr, main="SMR output adjusted for diffs")
points(coords_aes)
text(x=coords_aes[,1], y=coords_aes[,2],
     1:12,
     cex=.75, pos=4)

(df <- data.frame("measured_vals"=c(0.233400, 0.168745,0.255447,0.275018,0.173099,0.151764,0.180831,NaN,NaN,0.197050,0.149060,0.167377),
                  "raw_smr" = raster::extract(smr, coords_aes),
                  "adjusted_smr" = raster::extract(adjusted_smr, coords_aes)))


# import monitor values
# make up fake ones for now
smr_vals <- raster::extract(smr, coords_aes)
plot(smr_vals, ylim=c(.27, .33))
set.seed(4)
monitor_vals <- smr_vals + rnorm(12, sd=.005)
points(monitor_vals, pch=3, col='blue')

# calculate differences between monitors and SMR at location of monitors
diffs <- smr_vals - monitor_vals
plot(diffs)





# perform kriging on these values at the locations of the monitors
# kriging::kriging(x=coords_aes[,1], y=coords_aes[,2], diffs, model = "gaussian")


# modified from https://rpubs.com/nabilabd/118172
# first, convert to spatial dataframe (SPDF)
diffs_df <- data.frame(coords_aes[1], coords_aes[2], diffs=diffs)
coordinates(diffs_df) <- ~ east + north

# variogram
lzn.vgm <- variogram(diffs~1, diffs_df) # calculates sample variogram values
lzn.fit <- fit.variogram(lzn.vgm, model=vgm(1, "Sph", 900, 1)) # fit model


gstat::krige(z~1, coords_aes[,1:2])

# adjust SMR based on this kriged surface
# adjusted SMR will now pass through sensor values perfectly







### SAMPLE ###
### from http://rspatial.org/analysis/rst/4-interpolation.html

x <- read.csv("data/SMR/temp/airqual.csv")
x$OZDLYAV <- x$OZDLYAV * 1000

library(sp)
coordinates(x) <- ~LONGITUDE + LATITUDE
proj4string(x) <- CRS('+proj=longlat +datum=NAD83')
TA <- CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +datum=NAD83 +units=km +ellps=GRS80")
library(rgdal)
aq <- spTransform(x, TA)

cageo <- readRDS('data/SMR/temp/counties.rds')
ca <- spTransform(cageo, TA)
r <- raster(ca)
res(r) <- 10  # 10 km if your CRS's units are in km
g <- as(r, 'SpatialGrid')

library(gstat)
gs <- gstat(formula=OZDLYAV~1, locations=aq)
v <- variogram(gs, width=20)
head(v)

plot(v)

fve <- fit.variogram(v, vgm(85, "Exp", 75, 20))
fve
plot(variogramLine(fve, 400), type='l', ylim=c(0,120))
points(v[,2:3], pch=20, col='red')

fvs <- fit.variogram(v, vgm(85, "Sph", 75, 20))
fvs
plot(variogramLine(fvs, 400), type='l', ylim=c(0,120) ,col='blue', lwd=2)
points(v[,2:3], pch=20, col='red')

plot(v, fve)

k <- gstat(formula=OZDLYAV~1, locations=aq, model=fve)
# predicted values
kp <- predict(k, g)
## [using ordinary kriging]
spplot(kp)

# variance
ok <- brick(kp)
ok <- mask(ok, ca)
names(ok) <- c('prediction', 'variance')
plot(ok)

library(gstat)
idm <- gstat(formula=OZDLYAV~1, locations=aq)
idp <- interpolate(r, idm)
## [inverse distance weighted interpolation]
idp <- mask(idp, ca)
plot(idp)

RMSE <- function(observed, predicted) {
  sqrt(mean((predicted - observed)^2, na.rm=TRUE))
}

f1 <- function(x, test, train) {
  nmx <- x[1]
  idp <- x[2]
  if (nmx < 1) return(Inf)
  if (idp < .001) return(Inf)
  m <- gstat(formula=OZDLYAV~1, locations=train, nmax=nmx, set=list(idp=idp))
  p <- predict(m, newdata=test, debug.level=0)$var1.pred
  RMSE(test$OZDLYAV, p)
}
set.seed(20150518)
i <- sample(nrow(aq), 0.2 * nrow(aq))
tst <- aq[i,]
trn <- aq[-i,]
opt <- optim(c(8, .5), f1, test=tst, train=trn)
opt


m <- gstat(formula=OZDLYAV~1, locations=aq, nmax=opt$par[1], set=list(idp=opt$par[2]))
idw <- interpolate(r, m)
## [inverse distance weighted interpolation]
idw <- mask(idw, ca)
plot(idw)

library(fields)
m <- Tps(coordinates(aq), aq$OZDLYAV)
tps <- interpolate(r, m)
tps <- mask(tps, idw)
plot(tps)

### END OF SAMPLE ###








## old code ##
plot(raster::raster("data/SMR/Aes/deep.mc_1002012.asc"), main="deep", zlim=c(.2,.35))
plot(raster::raster("data/SMR/Aes/rz.mc_1002012.asc"), main="rz", zlim=c(.2,.35))
plot(raster::raster("data/SMR/Aes/mc_1002012.asc"), main="mc", zlim=c(.2,.35))
