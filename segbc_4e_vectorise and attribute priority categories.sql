-- polygonise and attribute
  -- vectorise habitat
processing.run("gdal:polygonize", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/r1_clip.tif','BAND':1,'FIELD':'value','EIGHT_CONNECTEDNESS':False,'EXTRA':'','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_prioritisation_.gpkg'})
-- processing.run("native:pixelstopolygons", {'INPUT_RASTER':'/Users/glennehmke/MEGA/segbc/raster/r1_clip.tif','RASTER_BAND':1,'FIELD_NAME':'value','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_prioritisation.gpkg'})

-- save buffer areas as gpkg

-- difference buffer geoms from prioritisation
processing.run("native:difference", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas.gpkg|layername=segbc_buffer_areas','OVERLAY':'/Users/glennehmke/MEGA/segbc/raster/segbc_prioritisation.gpkg|layername=segbc_prioritisation','OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_gpkg_diff_prioritisation.gpkg','GRID_SIZE':None})
-- rename priority to value in difference layer
processing.run("native:refactorfields", {'INPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_gpkg_diff_prioritisation.gpkg','FIELDS_MAPPING':[{'alias': '','comment': '','expression': '"fid"','length': 0,'name': 'fid','precision': 0,'sub_type': 0,'type': 4,'type_name': 'int8'},{'alias': '','comment': '','expression': '"priority"','length': 0,'name': 'value','precision': 0,'sub_type': 0,'type': 2,'type_name': 'integer'}],'OUTPUT':'/Users/glennehmke/MEGA/segbc/raster/segbc_buffer_areas_gpkg_diff_prioritisation_f.gpkg'})
-- merge

-- import temp merge into db SRID 3308
drop table if exists segbc_prioritisation cascade;
alter table segbc_prioritisation
    drop column fid;
alter table segbc_prioritisation
    drop column layer;
alter table segbc_prioritisation
    drop column path;

SELECT DISTINCT
  value
FROM segbc_prioritisation;

SELECT DISTINCT
  segbc_prioritisation.value,
  segbc_prioritisation_lut.original_value
FROM segbc_prioritisation
FULL OUTER JOIN segbc_prioritisation_lut ON segbc_prioritisation.value = segbc_prioritisation_lut.original_value
-- WHERE
--   segbc_prioritisation_lut.original_value IS NULL
;

-- attribute regions TOO LONG!
CREATE TABLE tmp_segbc_study_area_3308 AS
SELECT
  segbc_study_area.id,
  segbc_study_area.lganame,
  ST_Transform(segbc_study_area.geom, 3308) AS geom
FROM segbc_study_area;
create index idx_tmp_segbc_study_area_3308_geom on tmp_segbc_study_area_3308 using gist (geom);

SELECT
  segbc_prioritisation.id,
  tmp_segbc_study_area_3308.id,
  ST_Intersection(segbc_prioritisation.geom, tmp_segbc_study_area_3308.geom) AS geom
FROM segbc_prioritisation
JOIN tmp_segbc_study_area_3308 ON ST_Intersects(segbc_prioritisation.geom, tmp_segbc_study_area_3308.geom)
;

select distinct
data_source
  FROM segbc_habitat_points

alter table segbc_prioritisation_lut
    add constraint segbc_prioritisation_lut_pk
        primary key (original_value);
alter table segbc_prioritisation_lut
    add constraint segbc_prioritisation_lut_pk2
        unique (rank);
alter table segbc_prioritisation
  add constraint segbc_prioritisation_segbc_prioritisation_lut_original_value_fk
    foreign key (value) references segbc_prioritisation_lut (original_value);

-- view for GIS
DROP VIEW IF EXISTS segbc_prioritisation_display;
CREATE VIEW segbc_prioritisation_display AS
SELECT
  row_number() over () AS id,
  segbc_prioritisation.value,
  segbc_prioritisation_lut.original_value,
  buffer_priority_desc,
  segbc_prioritisation_lut.habitat,
  segbc_prioritisation_lut.rank,
  segbc_prioritisation_lut.description,
  segbc_prioritisation.geom
FROM segbc_prioritisation
JOIN segbc_prioritisation_lut ON segbc_prioritisation.value = segbc_prioritisation_lut.original_value
;

-- summarise
WITH priority_habitat AS
  (SELECT
    row_number() over () AS id,
    segbc_prioritisation.value,
    segbc_prioritisation_lut.original_value,
    buffer_priority_desc,
    segbc_prioritisation_lut.habitat,
    segbc_prioritisation_lut.rank,
    segbc_prioritisation_lut.description,
    SUM(ST_Area(segbc_prioritisation.geom)) AS area
  FROM segbc_prioritisation
  JOIN segbc_prioritisation_lut ON segbc_prioritisation.value = segbc_prioritisation_lut.original_value
  GROUP BY
    segbc_prioritisation.value,
    segbc_prioritisation_lut.original_value,
    buffer_priority_desc,
    segbc_prioritisation_lut.habitat,
    segbc_prioritisation_lut.rank,
    segbc_prioritisation_lut.description
  ),
  regions AS
    (SELECT
      segbc_study_area.id AS region_id,
      segbc_study_area.lganame,
      ST_Area((ST_Transform(segbc_study_area.geom, 3308))) AS area
    FROM segbc_study_area
    )
SELECT
