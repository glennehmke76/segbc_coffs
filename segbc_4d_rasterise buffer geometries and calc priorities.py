# Rasterise buffer geometries, intersect with habitat layer and calculate priorities
# rasterise polygonal buffers for integration with habitat layer
processing.run("gdal:rasterize", {'INPUT':'postgres://dbname=\'birdata\' host=localhost port=5432 sslmode=disable key=\'tid\' srid=3308 type=MultiSurface checkPrimaryKeyUnicity=\'1\' table="public"."segbc_buffer_areas" (geom)','FIELD':'priority','BURN':0,'USE_Z':False,'UNITS':1,'WIDTH':5,'HEIGHT':5,'EXTENT':'9800220.024900001,9917705.865499999,4780771.016100000,4955831.280600000 [EPSG:3308]','NODATA':0,'OPTIONS':'','DATA_TYPE':2,'INIT':None,'INVERT':False,'EXTRA':'','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_r.tif'})

# calculate new raster value as intersection
processing.run("native:rastercalc", {'LAYERS':['/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_r.tif','/Users/glennehmke/MEGA/segbc/raster/segbc_habitat_reclass_simple.tif'],'EXPRESSION':'"segbc_buffer_areas_r@1" * "segbc_habitat_reclass_simple@1"','EXTENT':None,'CELL_SIZE':5,'CRS':QgsCoordinateReferenceSystem('EPSG:3308'),'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/r1.tif'})

# habitat
2 High_VeryHigh
5 Mod

#

# clip
processing.run("gdal:cliprasterbymasklayer", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/r1.tif','MASK':'/Users/glennehmke/MEGA/segbc/segbc_study_area_3308.gpkg|layername=segbc_study_area_3308','SOURCE_CRS':QgsCoordinateReferenceSystem('EPSG:3308'),'TARGET_CRS':QgsCoordinateReferenceSystem('EPSG:3308'),'TARGET_EXTENT':'9799491.214299999,9919577.919299999,4780771.016100000,4960455.943000000 [EPSG:3308]','NODATA':0,'ALPHA_BAND':False,'CROP_TO_CUTLINE':True,'KEEP_RESOLUTION':True,'SET_RESOLUTION':False,'X_RESOLUTION':None,'Y_RESOLUTION':None,'MULTITHREADING':False,'OPTIONS':'','DATA_TYPE':2,'EXTRA':'','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/r1_clip.tif'})

# make dual-band raster
# processing.run("gdal:merge", {'INPUT':['/Users/glennehmke/MEGA/segbc/raster/r1_clip.tif','/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_r.tif'],'PCT':False,'SEPARATE':True,'NODATA_INPUT':0,'NODATA_OUTPUT':0,'OPTIONS':'COMPRESS=NONE|BIGTIFF=IF_NEEDED','EXTRA':'','DATA_TYPE':2,'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/dual_band_prioritisation.tif'})

