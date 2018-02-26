library(rgdal)
library(rasterVis)
library(RColorBrewer)
library(scales)
library(viridis)
library(ggthemes) # theme_map()
library(gridExtra)
library(grid)


files <- list.files(path = './data/trimmed_ndre', full.names = T)
W_ndre <- files[113]
AES_ndre <- files[27]
OD_ndre <- files[74]
J_ndre <- files[44]

plot(raster(AES_ndre))
plot(raster(W_ndre))
plot(raster(OD_ndre))
plot(raster(J_ndre), main='J')

colr <- colorRampPalette(brewer.pal(9, 'Blues'))

W_rr <- rasterFromXYZ(W_r[,c(1,2,6)])
AES_rr <- rasterFromXYZ(AES_r[,c(1,2,6)])
OD_rr <- rasterFromXYZ(OD_r[,c(1,2,6)])
J_rr <- rasterFromXYZ(J_r[,c(1,2,6)])
raster_list <- c(W_rr, AES_rr, OD_rr, J_rr)
field_name <- c('W', 'AES', 'OD', 'J')
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
              at=seq(0.14, 0.25, len=101),
              main=field_name[i])
    plot(r)
}

#########

g_legend <- function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)}

legend <- g_legend(Jgg)

Wgg <- ggplot() +
    geom_raster(data=W_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_fixed() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field W - 06/30/2014')

AESgg <- ggplot() +
    geom_raster(data=AES_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_equal()+
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field AES - 06/07/2012')
AESgg
ODgg <- ggplot() +
    geom_raster(data=OD_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +    
    coord_equal() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field OD - 05/25/2012')

Jgg <- ggplot() +
    geom_raster(data=J_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_equal() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"), 
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20))+
    labs(fill='Soil Moisture') +
    ggtitle("Field J - 06/29/2013")

ggarrange(Jgg, AESgg, Wgg, ODgg, ncol=2, nrow=2, common.legend = T, legend = 'bottom')


# layout <- rbind(c(1, 2),
#                 c(3, 4),
#                 c(5, 5))
# 
# plot_grid(Jgg, AESgg, Wgg, ODgg, legend, layout_matrix = layout, rel_heights = c(3/7,3/7,1/7))
###########



###########

ggplot() +
    geom_tile(data=raster_soilM_plots, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.8) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85) +
    coord_equal() +
    theme_map()+
    theme(legend.position="bottom",
          legend.title.align = 0.5)+
    labs(fill='Soil Moisture') +
    theme(legend.key.width=unit(2, "cm")) +
    facet_grid(. ~ field)
