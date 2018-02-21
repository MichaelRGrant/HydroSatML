library(rgdal)
library(rasterVis)
library(RColorBrewer)

colr <- colorRampPalette(brewer.pal(9, 'Blues'))

W_rr <- rasterFromXYZ(W_r[,c(1,2,6)])
AES_rr <- rasterFromXYZ(AES_r[,c(1,2,6)])
OD_rr <- rasterFromXYZ(OD_r[,c(1,2,6)])
J_rr <- rasterFromXYZ(J_r[,c(1,2,6)])
raster_list <- c(W_rr, AES_rr, OD_rr, J_rr)
for(i in 1:4){
    r<-levelplot(raster_list[[i]], 
              margin=FALSE,                       # suppress marginal graphics
              colorkey=list(
                  space='bottom',                   # plot legend at bottom
                  labels=list(at=seq(0.1,0.3,0.01), font=4)      # legend ticks and labels 
              ),    
              par.settings=list(
                  axis.line=list(col='transparent') # suppress axes and legend outline
              ),
              scales=list(draw=FALSE),            # suppress axis labels
              col.regions=colr,                   # colour ramp
              at=seq(0.14, 0.25, len=101))
    plot(r)
}
