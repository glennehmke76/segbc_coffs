# reclassify habitat raster
1 littoralis_High
2 littoralis_Mod
3 littoralis_VeryHigh
4 torulosa_High
5 torulosa_Mod
6 torulosa_VeryHigh

to

2 littoralis_High_VeryHigh
4 littoralis_Mod
3 torulosa__High_VeryHigh
5 torulosa_Mod

# use range boundaries 2 (<= x <-)
processing.run("native:reclassifybytable", {'INPUT_RASTER':'/Users/glennehmke/MEGA/segbc/GBC_Habitat_Raster_NSW.tif/GBC_Habitat_Raster_NSW.tif','RASTER_BAND':1,'TABLE':['1','1','2','2','2','4','3','3','2','4','4','3','5','5','5','6','6','3','255','255','0'],'NO_DATA':0,'RANGE_BOUNDARIES':2,'NODATA_FOR_MISSING':False,'DATA_TYPE':0,'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_habitat_reclass.tif'})
Using classes:
1) 1 ≤ x ≤ 1 → 2
2) 2 ≤ x ≤ 2 → 4
3) 3 ≤ x ≤ 3 → 2
4) 4 ≤ x ≤ 4 → 3
5) 5 ≤ x ≤ 5 → 5
6) 6 ≤ x ≤ 6 → 3
7) 255 ≤ x ≤ 255 → 0


--
to

2 High_VeryHigh
5 Mod

# use range boundaries 2 (<= x <-)
processing.run("native:reclassifybytable", {'INPUT_RASTER':'/Users/glennehmke/MEGA/segbc/GBC_Habitat_Raster_NSW.tif/GBC_Habitat_Raster_NSW.tif','RASTER_BAND':1,'TABLE':['1','1','5','2','2','2','3','3','5','4','4','5','5','5','2','6','6','5'],'NO_DATA':0,'RANGE_BOUNDARIES':2,'NODATA_FOR_MISSING':False,'DATA_TYPE':0,'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_habitat_reclass_simple.tif'})

Using classes:
1) 1 ≤ x ≤ 1 → 5
2) 2 ≤ x ≤ 2 → 2
3) 3 ≤ x ≤ 3 → 5
4) 4 ≤ x ≤ 4 → 5
5) 5 ≤ x ≤ 5 → 2
6) 6 ≤ x ≤ 6 → 5