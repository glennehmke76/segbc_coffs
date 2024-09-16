-- Areas priorities
  -- priority scale as orders of magnitude for rater calculation
DROP TABLE IF EXISTS segbc_buffer_areas_tmp;
CREATE TEMPORARY TABLE segbc_buffer_areas_tmp AS
-- add categories as per recipe starting with high and excluding areas already added
-- hierarchically so we have non-overlapping buffers
SELECT
  1000 AS priority,
  'within 2km of a nest tree or drinking site' AS priority_desc,
  ST_Union(ST_Buffer(ST_Transform(geom, 3308), 2000)) AS geom
FROM segbc_habitat_points
WHERE
  data_source = 'nest trees'
  OR data_source = 'drinking sites'
;

INSERT INTO segbc_buffer_areas_tmp (priority, priority_desc, geom)
SELECT
  100 AS priority,
  'within 5km of a nest tree or drinking site' AS priority_desc,
  ST_Difference(buffered.geom, segbc_buffer_areas_tmp.geom) AS geom
FROM
    (SELECT
      ST_Union(ST_Buffer(ST_Transform(segbc_habitat_points.geom, 3308), 5000)) AS geom
    FROM segbc_habitat_points
    WHERE
      data_source = 'nest trees'
      OR data_source = 'drinking sites'
    )buffered, segbc_buffer_areas_tmp
;

INSERT INTO segbc_buffer_areas_tmp (priority, priority_desc, geom)
SELECT
  10 AS priority,
  'within 1km of a sighting with low density survey effort' AS priority_desc,
  ST_Difference(buffered.geom, ST_Union(segbc_buffer_areas_tmp.geom)) AS geom
FROM
    (SELECT
      ST_Union(ST_Buffer(ST_Transform(segbc_habitat_sightings_selected.geom, 3308), 1000)) AS geom
    FROM segbc_habitat_sightings_selected
    )buffered, segbc_buffer_areas_tmp
GROUP BY
  buffered.geom
;

DROP TABLE IF EXISTS segbc_buffer_areas;
CREATE TABLE segbc_buffer_areas AS
SELECT
  segbc_buffer_areas_tmp.priority,
  segbc_buffer_areas_tmp.priority_desc,
  ST_Intersection(ST_Transform(segbc_study_area.geom, 3308), segbc_buffer_areas_tmp.geom) AS geom
FROM segbc_buffer_areas_tmp
JOIN segbc_study_area ON ST_Intersects(ST_Transform(segbc_study_area.geom, 3308), segbc_buffer_areas_tmp.geom)
;


-- v2 buffer only for dashed lines
DROP VIEW IF EXISTS segbc_buffers_2km;
CREATE VIEW segbc_buffers_2km AS
SELECT
  buffer.priority_desc,
  ST_Intersection(ST_Transform(segbc_study_area.geom, 3308), buffer.geom) AS geom
FROM
  (SELECT
    'within 2km of a nest tree or drinking site' AS priority_desc,
    ST_Union(ST_Buffer(ST_Transform(geom, 3308), 2000)) AS geom
  FROM segbc_habitat_points
  WHERE
    data_source = 'nest trees'
    OR data_source = 'drinking sites'
  )buffer
JOIN segbc_study_area ON ST_Intersects(ST_Transform(segbc_study_area.geom, 3308), buffer.geom)
;



DROP VIEW IF EXISTS segbc_buffers_5km;
CREATE VIEW segbc_buffers_5km AS
SELECT
  row_number() over () AS id,
  buffer.priority_desc,
  ST_Intersection(ST_Transform(segbc_study_area.geom, 3308), buffer.geom) AS geom
FROM
  (SELECT
    'within 5km of a nest tree or drinking site' AS priority_desc,
    ST_Union(ST_Buffer(ST_Transform(geom, 3308), 5000)) AS geom
  FROM segbc_habitat_points
  WHERE
    data_source = 'nest trees'
    OR data_source = 'drinking sites'
  )buffer
JOIN segbc_study_area ON ST_Intersects(ST_Transform(segbc_study_area.geom, 3308), buffer.geom)
;

