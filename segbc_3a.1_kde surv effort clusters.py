# define high survey effort clusters
processing.run("qgis:heatmapkerneldensityestimation", {'INPUT':'postgres://dbname=\'birdata\' host=localhost port=5432 sslmode=disable key=\'_uid_\' checkPrimaryKeyUnicity=\'1\' table="(SELECT row_number() over () AS _uid_,* FROM (select *, ST_TRANSFORM(geom, 3308) as geom_3308 from segbc_surv_effort\n) AS _subq_1_\n)" (geom_3308)','RADIUS':3000,'RADIUS_FIELD':'','PIXEL_SIZE':100,'WEIGHT_FIELD':'','KERNEL':0,'DECAY':0,'OUTPUT_VALUE':0,'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_surv_effort_kde.tif'})
processing.run("gdal:contour_polygon", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_surv_effort_kde..tif','BAND':1,'INTERVAL':25,'CREATE_3D':False,'IGNORE_NODATA':False,'NODATA':None,'OFFSET':0,'EXTRA':'','FIELD_NAME_MIN':'density_min','FIELD_NAME_MAX':'density_max','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_surv_effort_kde_contours..gpkg'})

# manually select desired density contour and dissolve selected features (min density 100 chosen)
processing.run("native:dissolve", {'INPUT':QgsProcessingFeatureSourceDefinition('/Users/glennehmke/MEGA/segbc/raster/segbc_surv_effort_kde_contours..gpkg|layername=contour', selectedFeaturesOnly=True, featureLimit=-1, geometryCheck=QgsFeatureRequest.GeometryAbortOnInvalid),'FIELD':[],'SEPARATE_DISJOINT':False,'OUTPUT':'TEMPORARY_OUTPUT'})

# explode to multipolygons
processing.run("native:multiparttosingleparts", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/hab_points_KDE_contours_50.gpkg|layername=contour','OUTPUT':'TEMPORARY_OUTPUT'})
  # re-attribute FID / ID so is unique
# import to db
