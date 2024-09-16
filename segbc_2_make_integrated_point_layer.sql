-- make integrated sightings table for analysis
DROP TABLE IF EXISTS segbc_habitat_points;
CREATE TABLE segbc_habitat_points (
  id integer not null,
  data_source text not null,
  dataset_source text default null,
  dataset_id integer default null, -- the dataset survey primary key
  date date default null,
  geom geometry(Point,4283)
);
create index sidx_tmp_habitat_points_geom on segbc_habitat_points using gist (geom);
create sequence segbc_habitat_points_seq as integer;
alter sequence segbc_habitat_points_seq owned by segbc_habitat_points.id;

-- dump nest trees
INSERT INTO segbc_habitat_points (id, data_source, dataset_id, geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'nest trees',
  id,
  geom
FROM segbc_nest_trees
;

-- dump drinking sites
INSERT INTO segbc_habitat_points (id, data_source, geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'drinking sites',
  geom
FROM segbc_drinking_sites
;

-- dump coffs_gc_priority
INSERT INTO segbc_habitat_points (id, data_source, dataset_id, geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'coffs_gc_priority',
  id,
  geom
FROM segbc_coffs_gc_priority
;

-- dump bionet sightings
INSERT INTO segbc_habitat_points (id, data_source, dataset_source, dataset_id, "date", geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'bionet',
  segbc_bionet.datasetnam,
  segbc_bionet.id,
  TO_DATE(SPLIT_PART(datefirst, ' ', 1), 'DD/MM/YYYY') AS start_date,
  geom
FROM segbc_bionet
;

-- dump Biliirrgan App Records (2023)
INSERT INTO segbc_habitat_points (id, data_source, dataset_id, "date", geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'biliirrgan_2023',
  id,
  TO_DATE(SPLIT_PART("what is th", ' ', 1), 'MM/DD/YYYY') AS start_date,
  geom
FROM segbc_biliirrgan_2023
;

-- dump birdata sightings
  -- add normal sightings
  INSERT INTO segbc_habitat_points (id, data_source, dataset_source, dataset_id, date, geom)
  SELECT
    nextval('segbc_habitat_sightings_seq'),
    'birdata_265_sighting',
    source.name,
    survey.id,
    survey.start_date,
    survey_point.geom AS geom
  FROM survey
  JOIN survey_point ON survey.survey_point_id = survey_point.id
  JOIN sighting ON survey.id = sighting.survey_id
  JOIN source ON survey.source_id = source.id
  JOIN survey_type ON survey.survey_type_id = survey_type.id
  JOIN segbc_study_area ON ST_Intersects(survey_point.geom, segbc_study_area.geom)
  WHERE
    sighting.species_id = 265
    AND sighting.individual_count > 0
  ;

  -- pseudo-sightings from chewings codes
  INSERT INTO segbc_habitat_points (id, data_source, dataset_source, dataset_id, date, geom)
  SELECT
    nextval('segbc_habitat_sightings_seq'),
    'birdata_265_pseudo_sighting',
    source.name,
    survey.id,
    survey.start_date,
    survey_point.geom AS geom
  FROM survey
  JOIN survey_point ON survey.survey_point_id = survey_point.id
  JOIN sighting ON survey.id = sighting.survey_id
  JOIN source ON survey.source_id = source.id
  JOIN survey_type ON survey.survey_type_id = survey_type.id
  JOIN segbc_study_area ON ST_Intersects(survey_point.geom, segbc_study_area.geom)
  JOIN segbc_survey_feed_tree_chewings ON survey.id = segbc_survey_feed_tree_chewings.survey_id
  WHERE
    segbc_survey_feed_tree_chewings.chewings_id <= 3
    AND sighting.individual_count IS NULL
  ;

-- remove duplicated data
SELECT DISTINCT
  data_source, dataset_source
FROM segbc_habitat_points;

DELETE
FROM segbc_habitat_points
WHERE
  (data_source = 'bionet' AND dataset_source = 'Birdlife Australia - Birdata (2004 - 2016)')
  OR (data_source = 'bionet' AND dataset_source = 'Birdlife Australia - Birds in Backyards')
  OR (data_source = 'bionet' AND dataset_source = 'Birdlife Australia - Birdata')
  OR (data_source = 'bionet' AND dataset_source = 'Birdlife Australia - Atlas Record Forms')
;

-- 7th june 2024 add kml data from Jess email this date
INSERT INTO segbc_habitat_points (id, data_source, dataset_source, dataset_id, "date", geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'drinking sites',
  'Jess email 7th June 2024',
  NULL,
  '01/01/2024' AS start_date,
  geom
FROM tmp_segbc_import
WHERE name = 'Frequent drinking location'
;

INSERT INTO segbc_habitat_points (id, data_source, dataset_source, dataset_id, "date", geom)
SELECT
  nextval('segbc_habitat_sightings_seq'),
  'Jess email 7th June 2024_sighting',
  'Jess email 7th June 2024',
  NULL,
  '01/01/2024' AS start_date,
  geom
FROM tmp_segbc_import
WHERE name <> 'Frequent drinking location'
;

