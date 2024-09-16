# KDE point reduction
# point reduction - replace dense point clusters with a single centroid of an upper volume contour
  # 500m bandwidth
processing.run("qgis:heatmapkerneldensityestimation", {'INPUT':'memory://Point?crs=EPSG:3308&field=id:integer(-1,0)&field=data_source:string(-1,0)&field=dataset_source:string(-1,0)&field=dataset_id:integer(-1,0)&field=date:date(-1,0)&uid={34f1de62-9070-4122-b526-67931722d4e6}','RADIUS':500,'RADIUS_FIELD':'','PIXEL_SIZE':50,'WEIGHT_FIELD':'','KERNEL':0,'DECAY':0,'OUTPUT_VALUE':0,'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/hab_points_KDE_50.tif'})
# make vector polygons from KDE raster
processing.run("gdal:contour_polygon", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/hab_points_KDE_50.tif','BAND':1,'INTERVAL':5,'CREATE_3D':False,'IGNORE_NODATA':False,'NODATA':None,'OFFSET':0,'EXTRA':'','FIELD_NAME_MIN':'density_min','FIELD_NAME_MAX':'density_max','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/hab_points_KDE_contours_50.gpkg'})
# explode to multipolygons
processing.run("native:multiparttosingleparts", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/hab_points_KDE_contours_50.gpkg|layername=contour','OUTPUT':'TEMPORARY_OUTPUT'})
  # re-attribute FID / ID so is unique
# import to db