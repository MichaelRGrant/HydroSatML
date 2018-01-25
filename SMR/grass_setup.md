## Aes

# import elevation file
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Elevation/Aes_el.asc location=Aes output=aes_el

# import bulk density files
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/aes_BD_1.tif output=aes_bd_1
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/aes_BD_2.tif output=aes_bd_2
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/aes_BD_3.tif output=aes_bd_3
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/aes_BD_4.tif output=aes_bd_4
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/aes_BD_5.tif output=aes_bd_5

# import clay files
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/aes_clay_1.tif output=aes_cl_1
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/aes_clay_2.tif output=aes_cl_2
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/aes_clay_3.tif output=aes_cl_3
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/aes_clay_4.tif output=aes_cl_4
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/aes_clay_5.tif output=aes_cl_5


## J

# import elevation file
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Elevation/J_el.asc location=J output=j_el

# import bulk density files
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/jns_BD_1.tif output=j_bd_1
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/jns_BD_2.tif output=j_bd_2
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/jns_BD_3.tif output=j_bd_3
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/jns_BD_4.tif output=j_bd_4
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/jns_BD_5.tif output=j_bd_5


## Od

# import elevation file
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Elevation/Od_el.asc location=Od output=od_el

# import bulk density files
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/odb_BD_1.tif output=od_bd_1
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/odb_BD_2.tif output=od_bd_2
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/odb_BD_3.tif output=od_bd_3
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/odb_BD_4.tif output=od_bd_4
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/odb_BD_5.tif output=od_bd_5


## W

# import elevation file
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Elevation/W_el.asc location=W output=w_el

# import bulk density files (HAS OVERRIDE TO FORCE PROJECTION THAT DOES NOT MATCH)
r.in.gdal -o input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/wlf_BD_1.tif output=w_bd_1
r.in.gdal -o input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/wlf_BD_2.tif output=w_bd_2
r.in.gdal -o input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/wlf_BD_3.tif output=w_bd_3
r.in.gdal -o input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/wlf_BD_4.tif output=w_bd_4
r.in.gdal -o input=C:/Users/drjor/Documents/grassdata/SMR/BulkDensity/wlf_BD_5.tif output=w_bd_5

# import clay files
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/wlf_clay_1.tif output=w_cl_1
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/wlf_clay_2.tif output=w_cl_2
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/wlf_clay_3.tif output=w_cl_3
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/wlf_clay_4.tif output=w_cl_4
r.in.gdal input=C:/Users/drjor/Documents/grassdata/SMR/Clay/wlf_clay_5.tif output=w_cl_5


# load image viewing window (just x0 for MacOS)
d.mon wx0
# if wish to stop, type the following
# d.mon stop=wx0

# show image of elevation and bulk density
d.rast w_bd_1