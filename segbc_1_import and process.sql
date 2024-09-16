-- import layers in SRID 4283

-- segbc_lwf_properties
  -- give Land For Wildlife Properties (Pat Edwards) a primary key - override non-unique ID

-- segbc_study_area

-- Pull in supplied sightings data and integrate

  -- SEGBC BioNet Records (1900-2023); segbc_bionet
  -- SEGBC Biliirrgan App Records (2023); segbc_biliirrgan_2023
  -- 2022 Coffs Glossy Count and priority sites; segbc_coffs_gc_priority
  -- SEGBC Nest Trees (2023); segbc_nest_trees
  -- Coffs SEGBC drinking sites to May 2024; segbc_drinking_sites

  ALTER TABLE IF EXISTS segbc_drinking_sites
    ADD COLUMN geom geometry(Point,4283);

  -- Query returned successfully in 7 secs 606 msec.
  UPDATE segbc_drinking_sites
  SET geom = ST_SetSRID(ST_MakePoint("Longitude", "Latitude"), 4283);

-- un-transpose coordinates for segbc_coffs_gc_priority
  alter table segbc_coffs_gc_priority
      add x numeric;
  alter table segbc_coffs_gc_priority
      add y numeric;
  WITH xy AS
    (SELECT
       id,
       ST_X(geom) AS x,
       ST_Y(geom) AS y
    FROM segbc_coffs_gc_priority
    )
  UPDATE segbc_coffs_gc_priority
  SET
    x = transposed.x,
    y = transposed.y
  FROM
      (SELECT
        id,
        CASE
          WHEN y > 0 THEN y
          WHEN y < 0 THEN x
          END AS x,
        CASE
          WHEN x > 0 THEN y
          WHEN x < 0 THEN x
          END AS y
      FROM xy
      )transposed
  WHERE
    transposed.id = segbc_coffs_gc_priority.id
  ;
  alter table segbc_coffs_gc_priority
      add geom_corrected geometry(point, 4283);
  UPDATE segbc_coffs_gc_priority
  SET geom_corrected = ST_MakePoint(x,y)
  ;
  alter table segbc_coffs_gc_priority
    drop column geom;
  alter table segbc_coffs_gc_priority
      rename column geom_corrected to geom;
  create index sidx_segbc_coffs_gc_priority_geom
      on segbc_coffs_gc_priority using gist (geom);

-- 7th june 2024 add kml data from Jess email this date
-- import csv as tmp_segbc_import

-- add jess text email sighting
INSERT INTO public.tmp_segbc_import (name, x, y, geom) VALUES ('jess email sighting', 153.153039, -30.224039, null::geometry(Point,4283))

ALTER TABLE IF EXISTS tmp_segbc_import
  ADD COLUMN geom geometry(Point,4283);
UPDATE tmp_segbc_import
SET geom = ST_SetSRID(ST_MakePoint(x, y), 4283);

-- > go to segbc_2_make_integrated_point_layer.sql

-- Laura email 27 June
INSERT INTO segbc_habitat_points (id, data_source, date, geom)
VALUES (nextval('segbc_habitat_sightings_seq'), 'nest trees', '2024-01-01', ST_MakePoint(152.7062167, -30.42638764));
INSERT INTO segbc_habitat_points (id, data_source, date, geom)
VALUES (nextval('segbc_habitat_sightings_seq'), 'nest trees', '2024-01-01', ST_MakePoint(152.9341394, -30.51095859));
INSERT INTO segbc_habitat_points (id, data_source, date, geom)
VALUES (nextval('segbc_habitat_sightings_seq'), 'nest trees', '2024-01-01', ST_MakePoint(152.55701, -30.17958));
INSERT INTO segbc_habitat_points (id, data_source, date, geom)
VALUES (nextval('segbc_habitat_sightings_seq'), 'nest trees', '2024-01-01', ST_MakePoint(152.5629, -30.1858));

